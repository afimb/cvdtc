class UrlJob < ActiveJob::Base
  queue_as :default

  def perform(job_id)
    job = Job.find_waiting(job_id.to_i).first
    if job
      uri = URI(job.url)
      response = nil
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request request
      end

      if response['content-disposition'].present?
        filename = response['content-disposition'].match(/filename=(\"?)(.+)\1/)[2]
        job.name = job.filename = filename
        job.save
      end
      File.open(job.path_file, 'wb') { |f| f.write(response.body) }
      job.pending!
    else
      retry_job(wait: 10.seconds) if Job.where(id: job_id.to_i).any?
    end
  rescue
    job.error_code = 'INVALID_REQUEST'
    job.save
  end
end
