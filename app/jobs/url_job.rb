class UrlJob < ActiveJob::Base
  queue_as :default

  def perform(job_id)
    job = Job.find_pending(job_id.to_i).first
    if job
      File.open(job.path_file, 'wb') { |f| f.write(Net::HTTP.get(URI(job.url))) }
    else
      retry_job(wait: 10.seconds)
    end
  end
end
