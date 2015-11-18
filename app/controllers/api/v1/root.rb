module API
  module V1
    class Root < Grape::API
      mount API::V1::Authentication

      add_swagger_documentation(
          api_version: 'v1',
          hide_documentation_path: true,
          hide_format: true,
          base_path: 'api'
      )
    end
  end
end
