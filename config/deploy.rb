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

# rbenv
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.0'

# set :format, :pretty
set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/application.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/sessions vendor/bundle public/system public/uploads }

set :default_env, { path: "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_and_clean do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute release_path.join('bin/rake'), 'tmp:cache:clear'
        execute release_path.join('bin/rake'), 'assets:clean'
      end
    end
  end

  after :finishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
