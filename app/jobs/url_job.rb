class UrlJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    args = args.reduce
    job = Job.find_pending(args[:id]).first
    if job
      File.open(job.path_file, 'wb') { |f| f.write(Net::HTTP.get(URI(job.url))) }
      IevkitJob.perform_later(args)
    else
      retry_job(wait: 10.seconds)
    end
  end
end
