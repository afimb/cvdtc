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
    if @job.save
      flash[:notice] = 'Job started'
      redirect_to root_path
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
    params.require(:job).permit(
                    :iev_action,
                    :format,
                    :file,
                    :url,
                    :format_export
    )
  end
end
