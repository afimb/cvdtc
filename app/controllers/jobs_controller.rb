class JobsController < ApplicationController
  helper IevkitViews::Engine.helpers

  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :job, only: [:show, :progress, :short_url, :status, :validation, :convert, :download_validation, :download_convert]

  def index
    @jobs = Job.find_my_job(current_user).page(params[:page])
  end

  def show
    if @job.is_terminated?
      redirect_to @job.format_convert.present? ? convert_job_path(@job) : validation_job_path(@job)
    else
      progress_steps
    end
  end

  def progress
    progress_steps
    render json: @datas
  end

  def short_url
    respond_to do |format|
      format.js
    end
  end

  def status
    respond_to do |format|
      format.js
    end
  end

  def validation
    # TODO - Faire une classe services pour toutes les vars
    @transport_datas_selected = params[:type_td]
    @default_view = params[:default_view] ? params[:default_view].to_sym : :files
    @result, @datas, @sum_report, @errors = @job.send("#{@default_view}_views", (@transport_datas_selected != 'all' ? @transport_datas_selected : nil ))
    @elements_to_paginate = Kaminari.paginate_array(@datas)
                                    .page(params[:page])
                                    .per(ENV['NUMBER_RESULTS_PER_PAGE'])
  end

  def convert; end

  # def download
  #   datas, args = @job.download_result(params[:default_view])
  #   send_data datas, args
  # end

  def download_validation
    datas, args = @job.download_validation_report(params[:default_view])
    send_data datas, args
  end

  def download_convert
    datas, args = @job.download_conversion
    send_data datas, args
  end

  def cancel
    job = Job.find_with_id_and_user(params[:id], (user_signed_in? ? current_user.id : nil)).first
    job.ievkit_cancel_or_delete(:cancel)
    job.destroy
    flash[:notice] = 'Annulation effectuée avec succès'
    redirect_to root_path
  end

  def destroy
    job = Job.find_by(id: params[:id], user: current_user)
    job.ievkit_cancel_or_delete(:delete)
    job.destroy
    flash[:notice] = 'Suppression effectuée avec succès'
    redirect_to :back
  end

  private

  def job
    @job = Job.find(params[:id])
    @job.search = params[:q][:search] if params[:q]
    @current_menu = @job.convert_job? ? :convert : :validate
  rescue => _e
    flash[:notice] = 'Ce rapport de validation n\'existe plus'
    redirect_to root_path
  end

  def progress_steps
    @datas = @job.is_terminated? ? { redirect: job_path(@job) } : @job.progress_steps
  end
end
