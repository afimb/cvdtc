module API
  module V1
    class Root < Grape::API
      mount API::V1::Authentication
      mount API::V1::Job

      add_swagger_documentation(
        base_path: '/api/v1'
      )
    end
  end
end
