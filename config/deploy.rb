set :application, 'cvdtc'
set :repo_url, 'https://github.com/afimb/cvdtc.git'

set :deploy_user, 'deploy'
set :port, 22

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :ssh_options, {
    forward_agent: true,
    port: 22
}

# set :deploy_to, '/var/www/my_app'
set :scm, :git
set :use_sudo, false

set :keep_assets, 2

# rbenv
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.0'

# set :format, :pretty
set :log_level, :debug
set :pty, true

set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/sessions vendor/bundle public/system public/uploads }

set :default_env, { path: "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  after :finishing, :restart
  after :finishing, :cleanup

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end
end
