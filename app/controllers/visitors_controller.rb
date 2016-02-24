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
    @job.user = current_user
    file_or_url = params[:job][:file] ? params[:job][:file] : params[:job][:url]
    @job.record_file_or_url(file_or_url)
    if @job.save
      @job.launch_jobs(job_url(@job.id))
      flash[:notice] = I18n.t('job.status.pending')
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
                                :object_id_prefix,
                                :time_zone,
                                :max_distance_for_commercial,
                                :ignore_last_word,
                                :ignore_end_chars,
                                :max_distance_for_connection_link)
  end
end
