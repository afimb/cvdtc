module API
  module V1
    class Job < Grape::API
      version 'v1'
      format :json

      resource :jobs do
        desc 'List my jobs'
        get '/' do
          ::Job.where(user: current_user)
        end

        desc 'Get job with ID'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.format_for_api
          end
        end

        desc 'Get job parameters'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/parameters' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            ps = ParametersService.new(job)
            ps.validate_params
          end
        end

        desc 'Get progress steps job'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/progress' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.progress_steps
          end
        end

        desc 'Get status job'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/status' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            ::Job.statuses[job.status]
          end
        end

        desc 'Get result action report job'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/result_report' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.result_action_report
          end
        end

        desc 'Get action report job'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/action_report' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.action_report
          end
        end

        desc 'Get validation report job'
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          get '/validation_report' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.validation_report
          end
        end

        desc 'Download result (CSV or Converted file)'
        params do
          requires :id, type: Integer, desc: 'Job id.'
          optional :default_view, type: String, desc: 'files or lines'
        end
        route_param :id do
          get '/download' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            datas, args = job.download_result(params[:default_view])
            content_type args[:type]
            env['api.format'] = :binary
            header 'Content-Disposition', "attachment; filename*=UTF-8''#{args[:filename]}"
            body datas
          end
        end

        desc 'Cancel job '
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          delete '/cancel' do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.ievkit_cancel_or_delete(:cancel)
            job.destroy
            body false
          end
        end

        desc 'Delete job '
        params do
          requires :id, type: Integer, desc: 'Job id.'
        end
        route_param :id do
          delete do
            job = ::Job.find_by(id: params[:id], user: current_user)
            error! :not_found, 404 unless job
            job.ievkit_cancel_or_delete(:delete)
            job.destroy
            body false
          end
        end

        desc 'Post new url job'
        params do
          requires :format, type: Integer, desc: 'Format'
          requires :url, type: String, desc: 'URL'
          requires :iev_action, type: Integer, desc: 'Action'
          optional :format_convert, type: Integer, desc: 'Format to convert'
          optional :object_id_prefix, type: String, desc: 'IDs prefix'
          optional :time_zone, type: String, desc: 'Time zone'
          optional :ignore_last_word, type: Boolean, desc: 'Ignore the last word'
          optional :ignore_end_chars, type: Integer, desc: 'Ignore the last n characters'
          optional :max_distance_for_commercial, type: Integer, desc: 'Max distance to produce zones ( in meters )'
          optional :max_distance_for_connection_link, type: Integer, desc: 'Max distance to create connections'
          optional :parameters, type: String, desc: 'JSON for parameters'
        end
        post '/url' do
          job = ::Job.new
          job.user = current_user
          job.format = params[:format].to_i
          job.iev_action = params[:iev_action].to_i
          job.format_convert = params[:format_convert].to_i if params[:format_convert].present?
          job.object_id_prefix = params[:object_id_prefix ]
          job.time_zone = params[:time_zone ]
          job.ignore_last_word = params[:ignore_last_word] if params[:ignore_last_word].present?
          job.ignore_end_chars = params[:ignore_end_chars].to_i
          job.max_distance_for_commercial = params[:max_distance_for_commercial].to_i
          job.max_distance_for_connection_link = params[:max_distance_for_connection_link].to_i
          job.url = params[:url]
          job.parameters = JSON.parse(params[:parameters]) if params[:parameters].present?
          if job.save
            url = Rails.application.routes.url_helpers.job_url(job.id)
            job.launch_jobs(url)
            job
          else
            job.errors.messages
          end
        end

        desc 'Post new file job'
        params do
          requires :format, type: Integer, desc: 'Format'
          requires :file, type: File, desc: 'File'
          requires :iev_action, type: Integer, desc: 'Action'
          optional :format_convert, type: Integer, desc: 'Format to convert'
          optional :object_id_prefix, type: String, desc: 'IDs prefix'
          optional :time_zone, type: String, desc: 'Time zone'
          optional :ignore_last_word, type: Boolean, desc: 'Ignore the last word'
          optional :ignore_end_chars, type: Integer, desc: 'Ignore the last n characters'
          optional :max_distance_for_commercial, type: Integer, desc: 'Max distance to produce zones ( in meters )'
          optional :max_distance_for_connection_link, type: Integer, desc: 'Max distance to create connections'
        end
        post '/file' do
          job = ::Job.new
          job.user = current_user
          job.format = params[:format].to_i
          job.iev_action = params[:iev_action].to_i
          job.format_convert = params[:format_convert].to_i if params[:format_convert].present?
          job.object_id_prefix = params[:object_id_prefix ]
          job.time_zone = params[:time_zone ]
          job.ignore_last_word = params[:ignore_last_word] if params[:ignore_last_word].present?
          job.ignore_end_chars = params[:ignore_end_chars].to_i
          job.max_distance_for_commercial = params[:max_distance_for_commercial].to_i
          job.max_distance_for_connection_link = params[:max_distance_for_connection_link].to_i
          job.file = params[:file]
          if job.save
            url = Rails.application.routes.url_helpers.job_url(job.id)
            job.launch_jobs(url)
            job
          else
            job.errors.messages
          end
        end
      end
    end
  end
end
