class VisitorsController < ApplicationController
  def index
    @current_menu = :validate
    job { @job.iev_action = :validate_job }
  end

  def convert
    @current_menu = :convert
    job { @job.iev_action = :convert_job }
    render 'index'
  end

  def create
    @job = Job.new(job_params)
    @job.user = current_user
    @job.file = params[:job][:file] if params[:job][:file].present?
    @job.url = params[:job][:url] if params[:job][:url].present?
    if @job.save
      @job.launch_jobs(job_url(@job.id))
      flash[:notice] = I18n.t('job.status.pending')
      redirect_to job_path(@job)
    else
      render 'index'
    end
  end

  def parameters_file
    data = ParametersService.validate_params_3.merge!(
      ParametersService.validate_params_4
    )
    send_data JSON.pretty_generate(data), { filename: 'cvdtc_parameters.json' }
  end

  def list_tests
    @format = params[:format]
    ievkit_job = Ievkit::Job.new('anonymous')
    @list_tests = ievkit_job.list_tests('validator', @format)
  end

  private

  def job
    @job = Job.new(object_id_prefix: 'cvd')
    yield if block_given?
  end

  def job_params
    params.require(:job).permit(:iev_action,
                                :format,
                                :format_convert,
                                :object_id_prefix,
                                :time_zone,
                                :max_distance_for_commercial,
                                :ignore_last_word,
                                :ignore_end_chars,
                                :max_distance_for_connection_link)
  end
end
