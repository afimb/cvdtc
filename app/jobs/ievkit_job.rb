class IevkitJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    args = args.reduce
    @job = Job.find_pending(args[:id]).first
    if @job && File.file?(@job.path_file)
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

      if forwarding_url.blank? || forwarding_url['error_code']
        retry_job(wait: 30.seconds)
        return
      end
      @job.scheduled!
      @job.links.create(name: 'forwarding_url', url: forwarding_url)
      # links = ievkit.get_job(forwarding_url)
      # if links.is_a? Hash
      #   links.each do |link|
      #     @job.links.build(name: link[0], url: link[1])
      #   end
      # end
      @job.short_url = args[:job_url]
      @job.save
    else
      retry_job(wait: 30.seconds)
    end
  end
end
