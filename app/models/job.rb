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

  attr_reader :all_links
  after_initialize :load_ievkit

  def name=(name)
    super(File.basename(name, File.extname(name)).humanize)
  end

  def file=(file)
    if file.present?
      super(clean_filename(file.original_filename))
      File.open(path_file, 'wb') { |f| f.write(file.read) }
    end
  rescue => e
    errors[:file] = I18n.t('job.unable_to_proceed', message: e.message)
  end

  def url=(url)
    self.name = clean_filename(url) if url.present?
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

  # def record_file_or_url(file_uploaded_or_url)
  #   return if file_uploaded_or_url[:file].blank? && file_uploaded_or_url[:url].blank?
  #
  #   self.file = file_uploaded_or_url[:file].original_filename if file_uploaded_or_url[:url].blank?
  #   fullpath_file = path_file
  #
  #   if url.blank?
  #     begin
  #       File.open(fullpath_file, 'wb') { |f| f.write(file_uploaded_or_url[:file].read) }
  #     rescue => e
  #       errors[:url] = I18n.t('job.unable_to_proceed', message: e.message)
  #     end
  #   end
  # end

  def path_file
    filename = (url.present? ? clean_filename(url) : file)
    self.name ||= filename
    Rails.root.join('public', 'uploads', filename)
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

  def progress_steps
    datas = {}
    return { error_code: I18n.t("iev.errors.#{error_code.downcase}", default: error_code.downcase.humanize) } if error_code.present?
    return datas if @all_links.blank?
    if @all_links[:action_report].blank?
      update_links
    else
      report, _lines_ok, _lines_nok = action_report
      if report && report['action_report'] && report['action_report']['progression']
        report = report['action_report']['progression']
        index_current_step = report['current_step'].to_i - 1
        datas[:current_step] = report['current_step'].to_i
        datas[:steps_count] = report['steps_count'].to_i
        datas[:current_step_realized] = report['steps'][index_current_step]['realized'].to_i
        datas[:current_step_total] = report['steps'][index_current_step]['total'].to_i
        datas[:steps_percent] = datas[:current_step].percent_of(datas[:steps_count]).round(2)
        datas[:current_step_percent] = datas[:current_step_realized].percent_of(datas[:current_step_total]).round(2)
      end
    end
    datas
  end

  def action_report
    report = @ievkit.get_job(@all_links[:action_report])
    return unless report
    files = report['action_report']['files']
    lines = report['action_report']['lines']
    {
        report: report,
        result: report['action_report']['result'].downcase,
        lines: lines,
        lines_ok: (lines ? lines.count { |line| line['status'] == 'OK' } : 0),
        lines_nok: (lines ? lines.count { |line| line['status'] != 'OK' } : 0),
        files: files,
        files_ok: (files ? files.count { |file| file['status'] == 'OK' } : 0),
        files_nok: (files ? files.count { |file| file['status'] != 'OK' } : 0)
    }
  end

  def validation_report
    @ievkit.get_job(@all_links[:validation_report])
  end

  def convert_report
    file = @all_links[:output] ? @all_links[:output] : @all_links[:data]
    @ievkit.get_job(file)
  end

  def short_url=(url)
    super(url.present? ? Bitly.client.shorten(url).short_url : '')
  rescue => e
    logger.info "Unable to access shorten url services: #{e.message}"
  end

  def mine?(user)
    self.user == user
  end

  def launch_jobs(job_url)
    UrlJob.perform_later(id) if url.present?
    pending! unless url.present?
    IevkitJob.perform_later(id: id, job_url: job_url)
  end

  protected

  def load_ievkit
    @ievkit = Ievkit::Job.new(referential)
    list_links
  end

  def clean_filename(name)
    base = File.basename(name, File.extname(name))
    extname = File.extname(name)
    extname = '.zip' if extname.blank?
    [base.parameterize,'_', id, extname].join
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
