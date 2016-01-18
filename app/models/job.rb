class JobFormatValidator < ActiveModel::Validator
  def validate(record)
    if record.format_export
      if record.format_export.end_with?(record.format)
        record.errors[:format_export] << I18n.t('activerecord.errors.messages.invalid_format_export')
      end
    end
    if record.file && record.url
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
  validates :file_md5, presence: true
  validates_with JobFormatValidator

  enum iev_action: [ :validate_job, :export_job ]
  enum format: [ :gtfs, :neptune, :netex ]
  enum format_export: [ :export_gtfs, :export_neptune, :export_netex ] # TODO - Upgrade to Rails5 and add suffix http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum status: [ :scheduled, :terminated, :canceled ]
end
