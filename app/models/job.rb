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
  has_many :links, dependent: :destroy
  validates :name, presence: true
  validates :iev_action, presence: true
  validates :format, presence: true
  validates :file, presence: true, if: Proc.new { |a| a.url.blank? }
  validates :url, format: URI::regexp(%w(http https)), if: Proc.new { |a| a.url.present? }
  validates_with JobFormatValidator

  enum iev_action: [ :validate_job, :export_job ]
  enum format: [ :gtfs, :neptune, :netex ]
  enum format_export: [ :export_gtfs, :export_neptune, :export_netex ] # TODO - Upgrade to Rails5 and add suffix http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum status: [ :pending, :scheduled, :terminated, :canceled ]

  before_destroy :ievkit_delete
  after_destroy :delete_file

  scope :find_my_job, ->(user) { where(user: user).order(created_at: :desc) }
  scope :find_pending, ->(id) { where(id: id, status: Job.statuses[:pending]).limit(1) }
  scope :destroy_by_user, ->(id, user_id) { where('id = ? AND (user_id IS NULL OR user_id = ?)', id, user_id).destroy_all }

  def name=(name)
    super(File.basename(name, File.extname(name)).humanize)
  end

  def file=(name)
    super(clean_filename(name))
  end

  def list_links
    {}.tap{ |hash|
      self.links.map{ |link| hash[link.name.to_sym] = link.url}
    }
  end

  def record_file_or_url(file_uploaded)
    return unless file_uploaded && self.url
    self.file = file_uploaded.original_filename if file_uploaded && self.url.blank?

    begin
      File.open(path_file, "wb") { |f| self.url.blank? ? f.write(file_uploaded.read) : f.write(Net::HTTP.get(URI(self.url))) } # TODO => Put into a worker if URL
    rescue => e
      self.errors[:url] = I18n.t('job.unable_to_proceed', { message: e.message })
    end
  end

  def params_file
    File.join('public', 'validate_gtfs.json')
  end

  def path_file
    filename = (self.url.present? ? clean_filename(self.url) : self.file)
    self.name ||= filename
    File.join('public', 'uploads', filename)
  end

  def ievkit_delete
    link = self.list_links[:delete]
    if link
      ievkit = Ievkit::Job.new(ENV['IEV_REFERENTIAL'])
      ievkit.delete_job(link)
    end
  end

  def is_terminated?
    links = self.list_links
    return false unless links.present?
    return true if self.terminated?
    ievkit_job = Ievkit::Job.new(ENV['IEV_REFERENTIAL'])
    result = ievkit_job.terminated_job?(links[:forwarding_url])
    self.terminated! if result
    result
  end

  def progress_steps
    datas = {}
    if list_links
      ievkit_job = Ievkit::Job.new(ENV['IEV_REFERENTIAL'])
      report = ievkit_job.get_job(list_links[:action_report])
      if report['action_report'] && report['action_report']['progression']
        report = report['action_report']['progression']
        index_current_step = report['current_step'].to_i - 1

        datas = {
          current_step: report['current_step'].to_i,
          steps_count: report['steps_count'].to_i,
          current_step_realized: report['steps'][index_current_step]['realized'].to_i,
          current_step_total: report['steps'][index_current_step]['total'].to_i
        }
        datas[:steps_percent] = datas[:current_step].percent_of(datas[:steps_count]).round(2)
        datas[:current_step_percent] = datas[:current_step_realized].percent_of(datas[:current_step_total]).round(2)
      end
    end
    datas
  end

  protected

  def clean_filename(name)
    base = File.basename(name, File.extname(name))
    [base.parameterize, File.extname(name)].join
  end

  def delete_file
    File.delete(path_file)
  rescue => e
    logger.info "File not found to delete: #{e.message}"
  end

end
