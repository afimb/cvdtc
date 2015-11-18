Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'visitors#index'
  devise_for :users
  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/documentation'
end
