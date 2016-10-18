Rails.application.routes.draw do
  default_url_options host: Rails.application.secrets.domain_name

  # Application
  root to: 'visitors#index'
  get 'convert', to: 'visitors#convert', as: 'convert'
  post 'jobs', to: 'visitors#create', as: 'jobs'
  get 'parameters', to: 'visitors#parameters', as: 'parameters'
  get 'parameters_file', to: 'visitors#parameters_file', as: 'parameters_file'
  get 'definition_tests', to: 'visitors#definition_tests', as: 'definition_tests'
  get 'list_tests/:format', to: 'visitors#list_tests', as: 'list_tests'
  get 'job/:id', to: 'jobs#show', as: 'job'
  get 'job/:id/progress', to: 'jobs#progress', as: 'progress_job'
  get 'job/:id/short_url', to: 'jobs#short_url', as: 'short_url'
  get 'job/:id/status', to: 'jobs#status', as: 'status_job'
  get 'job/:id/validation', to: 'jobs#validation', as: 'validation_job'
  get 'job/:id/validation/download', to: 'jobs#download_validation', as: 'download_validation_job'
  get 'job/:id/convert', to: 'jobs#convert', as: 'convert_job'
  get 'job/:id/convert/download', to: 'jobs#download_convert', as: 'download_convert_job'
  delete 'job/:id', to: 'jobs#destroy', as: 'destroy_job'
  delete 'job/:id/cancel', to: 'jobs#cancel', as: 'cancel_job'

  authenticate :user do
    get 'jobs', to: 'jobs#index'
  end

  # Devise
  devise_for :users
  devise_scope :user do
    get 'renew_token', to: 'users/registrations#renew_token', as: 'user_renew_token'
  end

  # Grape
  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/documentation'

  # RailsAdmin and Sidekiq
  authenticate :user, ->(u) { u.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
  end
end
