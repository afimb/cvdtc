Rails.application.routes.draw do
  # Application
  root to: 'visitors#index'
  get 'export', to: 'visitors#export', as: 'export'
  post 'jobs', to: 'visitors#create', as: 'jobs'

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
