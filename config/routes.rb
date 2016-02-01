Rails.application.routes.draw do
  # Application
  root to: 'visitors#index'
  get 'export', to: 'visitors#export', as: 'export'
  post 'jobs', to: 'visitors#create', as: 'jobs'
  get 'job/:id', to: 'jobs#show', as: 'job'
  get 'job/:id/progress', to: 'jobs#progress', as: 'progress_job'
  get 'job/:id/report', to: 'jobs#report', as: 'report_job'
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
