source 'https://rubygems.org'
ruby '2.3.0'
gem 'bundler', '~> 1.11'
gem 'rails', '~> 4.2.6'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 2.7.2'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails', '~> 4.0.5'
gem 'turbolinks', '~> 2.5.3'
gem 'jbuilder', '~> 2.0'
gem 'spring', '~> 1.5.0'
gem 'devise', '~> 3.5.6'
gem 'figaro', '~> 1.1.1'
gem 'high_voltage', '~> 2.4.0'
gem 'pg', '~> 0.18.4'
gem 'simple_form', '~> 3.2.0'
gem 'nprogress-rails', '~> 0.1.6.7'
gem 'rails_admin', '~> 0.7.0'
gem 'grape', '~> 0.13.0'
gem 'grape_logging', '~> 1.1.2'
gem 'grape-attack', '~> 0.1.1'
gem 'grape-swagger', '~> 0.20.1'
gem 'grape-swagger-rails', '~> 0.2.0'
gem 'sidekiq', '~> 4.0.1'
gem 'sinatra', '~> 1.4.6', require: nil
#gem 'ievkit', github: 'afimb/ievkit', branch: 'master'
gem 'ievkit', '~> 0.1.0'
gem 'bitly', '~> 0.10.4'
gem 'kaminari', '~> 0.16.3'
gem 'therubyracer', '~> 0.12.2'

# I18n
gem 'rails-i18n', '~> 4.0.7'
gem 'devise-i18n', '~> 0.12.1'
gem 'devise-i18n-views', '~> 0.3.7'
gem 'kaminari-i18n', '~> 0.3.2'
gem 'cvdtc-i18n', git: 'https://github.com/afimb/cvdtc-i18n.git'
# gem 'cvdtc-i18n', path: '../cvdtc-i18n', branch: :master

group :production, :staging do
  gem 'newrelic_rpm'
end
group :production, :preprod, :staging do
  gem 'rails_12factor', '~> 0.0.3'
end
group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-rescue'
end
group :development do
  gem 'puma', '~> 3.3'
  gem 'web-console', '~> 2.0'
  gem 'better_errors'
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-bundler', '~> 1.1.4'
  gem 'capistrano-rails', '~> 1.1.5'
  gem 'capistrano-rails-console', '~> 1.0.2'
  gem 'capistrano-rbenv', '~> 2.0.4'
  gem 'capistrano-sidekiq', '~> 0.5.4'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'spring-commands-rspec'
  gem 'letter_opener'
  gem 'bundler-audit'
  gem 'localeapp'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 3.0'
end

# Rails Assets
source 'https://rails-assets.org' do
  gem 'rails-assets-html5shiv', '~> 3.7.3'
  gem 'rails-assets-respond', '~> 1.4.2'
  gem 'rails-assets-bootstrap', '~> 3.3.6'
  gem 'rails-assets-bootstrap-material-design', '~> 0.3.0'
  gem 'rails-assets-clipboard', '~> 1.5.5'
  gem 'rails-assets-jquery-highlightRegex', '~> 0.1.2'
  gem 'rails-assets-bootstrap-filestyle', '~> 1.2.1'
end
