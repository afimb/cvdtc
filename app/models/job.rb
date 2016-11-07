class JobFormatValidator < ActiveModel::Validator
  def validate(record)
    if record.format_convert
      if record.format_convert.end_with?(record.format)
        record.errors[:format_convert] << I18n.t('activerecord.errors.messages.invalid_format_convert')
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
  validates :file, presence: true, if: proc { |a| a.url.blank? }
  validates :url, format: URI.regexp(%w(http https)), if: proc { |a| a.url.present? }
  validates_with JobFormatValidator

  enum iev_action: %w(validate_job convert_job)
  enum format: %w(gtfs neptune) # netex)
  enum format_convert: %w(convert_gtfs convert_neptune) # convert_netex) # TODO: Upgrade to Rails5 and add suffix http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum status: %w(waiting pending scheduled terminated canceled)

  after_destroy :delete_file

  scope :find_my_job, ->(user) { where(user: user).order(created_at: :desc) }
  scope :find_waiting, ->(id) { where(id: id, status: Job.statuses[:waiting]).limit(1) }
  scope :find_pending, ->(id) { where(id: id, status: Job.statuses[:pending]).limit(1) }
  scope :find_with_id_and_user, ->(id, user_id) { where('id = ? AND (user_id IS NULL OR user_id = ?)', id, user_id) }

  attr_reader :all_links, :result
  attr_accessor :search

  after_initialize :load_ievkit
  before_save :set_file_size

  def name=(name)
    cleaned_name = clean_filename(name, false)
    super(File.basename(cleaned_name, File.extname(cleaned_name)).humanize)
  end

  def filename=(name)
    super(clean_filename(name))
  end

  def file=(file_uploaded)
    self.name = self.filename = file_uploaded.original_filename
    File.open(path_file, 'wb') { |f| f.write(file_uploaded.read) }
    super(self.filename)
  rescue => e
    errors[:file] = I18n.t('job.unable_to_proceed', message: e.message)
  end

  def url=(url)
    self.name = self.filename = url
    super
  end

  def referential
    user ? user.id : ENV['IEV_REFERENTIAL']
  end

  def object_id_prefix=(name)
    super(name.parameterize) if name.present?
  end

  def list_links
    @all_links = {}.tap { |hash| links(true).map { |link| hash[link.name.to_sym] = link.url } }
  end

  def path_file
    Rails.root.join('public', 'uploads', self.filename)
  end

  def ievkit_cancel_or_delete(action)
    return if @all_links.blank?
    @ievkit.delete_job(@all_links[action.to_sym])
  end

  def is_terminated?
    return false if @all_links.blank?
    return true if terminated?
    if @ievkit.terminated_job?(@all_links[:forwarding_url])
      update_links
      terminated!
    else
      false
    end
  end

  def result
    IevkitViews::ActionReport.new(referential, @all_links[:action_report], 'action_report').result
  end

  def progress_steps
    datas = {}
    return { error_code: I18n.t("iev.errors.#{error_code.downcase}", default: error_code.downcase.humanize) } if error_code.present?
    return datas if @all_links.blank?
    if @all_links[:action_report].blank?
      update_links
    else
      ievkit_views = IevkitViews::ActionReport.new(referential, @all_links[:action_report], 'action_report')
      ievkit_views.progression
      datas = ievkit_views.datas
    end
    datas
  end

  def files_views(_type = nil)
    report = IevkitViews::ActionReport.new(referential, @all_links[:action_report], 'action_report', @all_links[:validation_report], search)
    [
      report.result,
      report.search_for(report.files),
      report.sum_report(report.files),
      report.errors
    ]
  end

  def transport_datas_views(type = nil)
    report = IevkitViews::ActionReport.new(referential, @all_links[:action_report], 'action_report', @all_links[:validation_report], search)
    if type
      datas = []
      datas << report.collections('line') if type == 'line'
      datas << report.objects(type) if type != 'line'
    else
      datas = [
        report.collections('line'),
        report.objects
      ]
    end
    files = report.sort_datas(datas)
    [
      report.result,
      report.search_for(files),
      report.sum_report(files),
      report.errors
    ]
  end

  def tests_views(_type = nil)
    report = IevkitViews::ValidationReport.new(referential, @all_links[:validation_report], 'validation_report', @all_links[:validation_report], search)
    [
      report.result,
      report.search_for(report.check_points),
      report.sum_report_for_tests(report.check_points),
      report.errors
    ]
  end

  def result_action_report
    report = @ievkit.get_job(@all_links[:action_report])
    return 'error' unless report
    report['action_report']['result'].downcase
  end

  # def action_report
  #   report = @ievkit.get_job(@all_links[:action_report])
  #   return unless report
  #   files = report['action_report']['files']
  #   lines = report['action_report']['lines']
  #   {
  #       report: report,
  #       result: report['action_report']['result']&.downcase,
  #       lines: lines,
  #       lines_ok: (lines ? lines.count { |line| line['status'] == 'OK' } : 0),
  #       lines_nok: (lines ? lines.count { |line| line['status'] != 'OK' } : 0),
  #       files: files,
  #       files_ok: (files ? files.count { |file| file['status'] == 'OK' } : 0),
  #       files_nok: (files ? files.count { |file| file['status'] != 'OK' } : 0)
  #   }
  # end

  def validation_report
    @ievkit.get_job(@all_links[:validation_report])
  end

  def download_result(default_view)
    default_view = default_view.present? ? default_view : 'files'
    self.convert_job? ? download_conversion : download_validation_report(default_view)
  end

  def download_validation_report(default_view)
    result, data, sum_report, errors = send("#{default_view}_views")
    csv = @ievkit.download_validation_report(data, errors)
    [csv, filename: "#{name.parameterize}-#{id}-#{Time.current.to_i}.csv"]
  end

  def download_conversion
    file = list_links[:output] ? list_links[:output] : list_links[:data]
    [convert_report, { filename: File.basename(file), type: 'application/zip' }]
  end

  def convert_report
    file = @all_links[:output] ? @all_links[:output] : @all_links[:data]
    @ievkit.disable_cache = true
    @ievkit.get_job(file)
  end

  def short_url=(url)
    super(url.present? ? Bitly.client.shorten(url).short_url : '')
  rescue => e
    logger.info "Unable to access shorten url services: #{e.message}"
  end

  def mine?(user)
    return false unless user && self.user
    self.user == user
  end

  def launch_jobs(job_url)
    if url.present?
      UrlJob.perform_later(id)
    else
      pending!
    end
    IevkitJob.perform_later(id: id, job_url: job_url)
  end

  def set_file_size
    if File.file?(path_file)
      size = File.size(path_file).to_f / 1024 / 1024
      self.file_size = size.round(2)
    end
  end

  def format_for_api
    attrs = [
      :id, :name, :format, :format_convert, :status, :object_id_prefix, :time_zone, :max_distance_for_commercial,
      :ignore_last_word, :ignore_end_chars, :max_distance_for_connection_link, :created_at, :updated_at, :short_url,
      :error_code, :file_size, :filename
    ]
    {}.tap{ |hash| attrs.map{ |attr| hash[attr] = send(attr) } }
  end

  def parameters
    self[:parameters].is_a?(Hash) ? self[:parameters].symbolize_keys! : {}
  end

  protected

  def load_ievkit
    @ievkit = Ievkit::Job.new(referential)
    list_links
  end

  def clean_filename(name, slug = true)
    base = File.basename(name, File.extname(name))
    extname = File.extname(name)
    extname = '.zip' if extname.blank?
    slug = slug ? "_#{SecureRandom.hex(5)}" : ''
    [base.parameterize, slug, extname].join
  end

  def delete_file
    File.delete(path_file)
  rescue => e
    logger.info "File not found to delete: #{e.message}"
  end

  def update_links
    url = @all_links[:forwarding_url]
    if @ievkit.terminated_job?(url)
      url = @ievkit.get_job(url)
      job_link = Link.find_or_initialize_by(job_id: id, name: 'terminated_job')
      job_link.url = url
      job_link.save
    end
    result = @ievkit.get_job(url)
    if result
      result.each do |link|
        job_link = Link.find_or_initialize_by(job_id: id, name: link[0])
        job_link.url = link[1]
        job_link.save
      end
    end
    list_links
  end
end
