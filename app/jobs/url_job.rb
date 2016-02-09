class UrlJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    job = Job.find_pending(args).first
    File.open(job.path_file, "wb") { |f| f.write(Net::HTTP.get(URI(job.url))) }
  end
end
