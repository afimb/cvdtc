module API
  module V1
    class Parameter < Grape::API
      version 'v1'
      format :json

      resource :parameters do
        desc 'List all parameters'
        get '/' do
          ParametersService.validate_params_3.merge!(ParametersService.validate_params_4)
        end
      end
    end
  end
end
