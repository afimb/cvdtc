class IevkitJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    @job = Job.find_pending(args).first
    if @job
      ievkit = Ievkit::Job.new(ENV['IEV_REFERENTIAL'])
      parameters = ParametersService.new(@job.format, { id: @job.id }, @job.format_convert)
      job_tmp_file = Rails.root.join('tmp', "parameters-#{@job.id}.json")
      File.open(job_tmp_file, 'wb') do |f|
        f.write parameters.to_json
      end
      forwarding_url = ievkit.post_job(:validator, @job.format, iev_file: @job.path_file, iev_params: job_tmp_file.to_s)
      if forwarding_url['error_code']
        retry_job(wait: 30.seconds)
        return
      end
      @job.scheduled!
      @job.links.create(name: 'forwarding_url', url: forwarding_url)
      links = ievkit.get_job(forwarding_url)
      if links.is_a? Array
        links.each do |link|
          @job.links.build(name: link[0], url: link[1])
        end
        @job.save
      end
    end
  end
end
