module API
  module V1
    class Authentication < Grape::API
      version 'v1'
      format :json

      resource :authentication do
        desc 'Return user informations'
        get :account do
          {
            email: current_user.email,
            name: current_user.name
          }
        end
      end
    end
  end
end
