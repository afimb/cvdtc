class IevkitJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    args = args.reduce
    @job = Job.find_pending(args[:id]).first
    if @job
      unless File.file?(@job.path_file)
        @job.error_code = 'FILE_NOT_FOUND'
        @job.save
        return
      end
      ievkit = Ievkit::Job.new(@job.referential)
      parameters = ParametersService.new(@job)
      job_tmp_file = Rails.root.join('tmp', "parameters-#{@job.id}.json")
      File.open(job_tmp_file, 'wb') do |f|
        f.write parameters.to_json
      end
      forwarding_url = if @job.format_convert
                         ievkit.post_job(:converter, nil, iev_file: @job.path_file.to_s, iev_params: job_tmp_file.to_s)
                       else
                         ievkit.post_job(:validator, @job.format, iev_file: @job.path_file.to_s, iev_params: job_tmp_file.to_s)
                       end

      if forwarding_url.blank?
        retry_job(wait: 10.seconds)
        return
      end

      if forwarding_url['error_code'].present?
        @job.error_code = forwarding_url['error_code']
        @job.save
        return
      end

      @job.scheduled!
      @job.links.create(name: 'forwarding_url', url: forwarding_url)
      @job.short_url = args[:job_url]
      @job.save
      Stat.create(format: @job.format, format_convert: @job.format_convert, user: @job.user, info: @job.name, file_size: @job.file_size)
    else
      retry_job(wait: 10.seconds)
    end
  end
end
