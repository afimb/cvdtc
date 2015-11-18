module API
  module V1
    class Authentication < Grape::API
      version 'v1'
      format :json

      resource :authentication do
        desc 'Return user informations'
        get :account do
          current_user
        end
      end
    end
  end
end
