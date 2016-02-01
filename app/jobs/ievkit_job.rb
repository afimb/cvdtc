class IevkitJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    @job = Job.find_pending(args).first
    if @job
      ievkit = Ievkit::Job.new(ENV['IEV_REFERENTIAL'])
      forwarding_url = ievkit.post_job(:validator, @job.format, iev_file: @job.path_file, iev_params: @job.params_file)
      if forwarding_url['error_code']
        retry_job
        return
      end
      @job.scheduled!
      @job.links.create(name: 'forwarding_url', url: forwarding_url)
      links = ievkit.get_job(forwarding_url)
      links.each do |link|
        @job.links.build(name: link[0], url: link[1])
      end
      @job.save
    end
  end
end
