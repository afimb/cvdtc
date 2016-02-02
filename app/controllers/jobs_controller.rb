class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :job, only: [:show, :progress, :report]

  def index
    @jobs = Job.find_my_job(current_user)
  end

  def show
    if @job.is_terminated?
      redirect_to report_job_path(@job)
    else
      progress_steps
    end
  end

  def progress
    progress_steps
    render json: @datas
  end

  def report

  end

  def cancel
    Job.destroy_by_user(params[:id], (user_signed_in? ? current_user.id : nil))
    redirect_to root_path
  end

  def destroy
    Job.destroy_all(id: params[:id], user: current_user)
    redirect_to root_path
  end

  private

  def job
    @job = Job.find(params[:id])
  end

  def progress_steps
    @datas = @job.is_terminated? ? { redirect: report_job_path } : @job.progress_steps
  end
end
