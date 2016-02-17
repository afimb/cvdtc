class VisitorsController < ApplicationController
  def index
    job { @job.iev_action = :validate_job }
  end

  def convert
    job { @job.iev_action = :convert_job }
    render 'index'
  end

  def create
    @job = Job.new(job_params)
    file_or_url = params[:job][:file] ? params[:job][:file] : params[:job][:url]
    @job.record_file_or_url(file_or_url)
    @job.user = current_user if user_signed_in?
    if @job.save
      flash[:notice] = I18n.t('job.status.pending')
      UrlJob.perform_later(@job.id) if @job.url.present?
      IevkitJob.perform_later(@job.id)
      @job.short_url = job_url(@job)
      @job.save
      redirect_to job_path(@job)
    else
      render 'index'
    end
  end

  private

  def job
    @job = Job.new
    yield if block_given?
  end

  def job_params
    params.require(:job).permit(:iev_action,
                                :format,
                                :url,
                                :format_convert,
                                :prefix,
                                :time_zone,
                                :max_distance_for_commercial,
                                :ignore_last_word,
                                :ignore_end_chars,
                                :max_distance_for_connection_link)
  end
end
