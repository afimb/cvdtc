class JobFormatValidator < ActiveModel::Validator
  def validate(record)
    if record.format_export
      if record.format_export.end_with?(record.format)
        record.errors[:format_export] << I18n.t('activerecord.errors.messages.invalid_format_export')
      end
    end
    if record.file.present? && record.url.present?
      record.errors[:file] << I18n.t('activerecord.errors.messages.choose_file_or_url')
      record.errors[:url] << I18n.t('activerecord.errors.messages.choose_file_or_url')
    end
  end
end

class Job < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates :iev_action, presence: true
  validates :format, presence: true
  validates :file, presence: true, if: Proc.new { |a| a.url.blank? }
  validates :url, format: URI::regexp(%w(http https)), if: Proc.new { |a| a.url.present? }
  validates_with JobFormatValidator

  enum iev_action: [ :validate_job, :export_job ]
  enum format: [ :gtfs, :neptune, :netex ]
  enum format_export: [ :export_gtfs, :export_neptune, :export_netex ] # TODO - Upgrade to Rails5 and add suffix http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum status: [ :scheduled, :terminated, :canceled ]

  def name=(name)
    super(File.basename(name, File.extname(name)).humanize)
  end

  def file=(name)
    super(clean_filename(name))
  end

  def record_file_or_url(file_uploaded)
    return unless file_upload && self.url

    if file_uploaded && self.url.blank?
      filename = self.file = file_uploaded.original_filename
    else
      filename = clean_filename(self.url)
    end

    self.name = filename
    path = Rails.root.join('public', 'uploads', filename)

    begin
      File.open(path, "wb") { |f| self.url.blank? ? f.write(file_uploaded.read) : f.write(Net::HTTP.get(URI(self.url))) } # TODO => Put into a worker if URL
    rescue => e
      self.errors[:url] = I18n.t('job.unable_to_proceed', { message: e.message })
    end
  end

  protected

  def clean_filename(name)
    base = File.basename(name, File.extname(name))
    [base.parameterize, File.extname(name)].join
  end

end
