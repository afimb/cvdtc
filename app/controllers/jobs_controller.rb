class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :job, only: [:show, :progress, :validation]

  def index
    @jobs = Job.find_my_job(current_user).page(params[:page])
  end

  def show
    if @job.is_terminated?
      redirect_to validation_job_path(@job)
    else
      progress_steps
    end
  end

  def progress
    progress_steps
    render json: @datas
  end

  def validation
    @report = @job.validation_report
  end

  def cancel
    job = Job.find_with_id_and_user(params[:id], (user_signed_in? ? current_user.id : nil))
    job.ievkit_cancel_or_delete(:cancel)
    job.destroy
    redirect_to root_path
  end

  def destroy
    job = Job.find_by(id: params[:id], user: current_user)
    job.ievkit_cancel_or_delete(:delete)
    job.destroy
    redirect_to root_path
  end

  private

  def job
    @job = Job.find(params[:id])
  end

  def progress_steps
    @datas = @job.is_terminated? ? { redirect: validation_job_path } : @job.progress_steps
  end
end
