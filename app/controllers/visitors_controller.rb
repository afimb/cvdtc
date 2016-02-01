class VisitorsController < ApplicationController
  def index
    job { @job.iev_action = :validate_job }
  end

  def export
    job { @job.iev_action = :export_job }
    render 'index'
  end

  def create
    @job = Job.new(job_params)
    @job.record_file_or_url(params[:job][:file])
    @job.user = current_user if user_signed_in?
    if @job.save
      flash[:notice] = I18n.t('job.status.pending')
      IevkitJob.perform_later(@job.id)
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
                                :format_export)
  end
end
