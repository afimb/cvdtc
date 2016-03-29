class UrlJob < ActiveJob::Base
  queue_as :default

  def perform(job_id)
    job = Job.find_waiting(job_id.to_i).first
    if job
      require 'open-uri'
      data = URI.parse(job.url).read

      if data.meta['content-disposition'].present?
        filename = data.meta['content-disposition'].match(/filename=(\"?)(.+)\1/)[2]
        job.name = job.filename = filename
        job.save
      end
      File.open(job.path_file, 'wb') { |f| f.write(data) }
      job.pending!
    else
      retry_job(wait: 10.seconds)
    end
  end
end
