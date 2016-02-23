Rails.application.routes.draw do
  # Application
  root to: 'visitors#index'
  get 'convert', to: 'visitors#convert', as: 'convert'
  post 'jobs', to: 'visitors#create', as: 'jobs'
  get 'job/:id', to: 'jobs#show', as: 'job'
  get 'job/:id/progress', to: 'jobs#progress', as: 'progress_job'
  get 'job/:id/short_url', to: 'jobs#short_url', as: 'short_url'
  get 'job/:id/validation', to: 'jobs#validation', as: 'validation_job'
  get 'job/:id/validation/download', to: 'jobs#download_validation', as: 'download_validation_job'
  get 'job/:id/convert', to: 'jobs#convert', as: 'convert_job'
  get 'job/:id/convert/download', to: 'jobs#download_convert', as: 'download_convert_job'
  delete 'job/:id', to: 'jobs#destroy', as: 'destroy_job'
  delete 'job/:id', to: 'jobs#cancel', as: 'cancel_job'

  authenticate :user do
    get 'jobs', to: 'jobs#index'
  end

  # Devise
  devise_for :users

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
