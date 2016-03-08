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

namespace :rails do
  desc "Start a rails console, for now just with the primary server"
  task :console do
    on roles(:app), primary: true do |role|
      rails_env = fetch(:rails_env)
      execute_remote_command "#{bundle_cmd_with_rbenv} #{current_path}/bin/rails console #{rails_env}"
    end
  end

  desc "Open the rails dbconsole on primary db server"
  task :dbconsole do
    on roles(:db), primary: true do
      rails_env = fetch(:stage)
      execute_remote_command "#{bundle_cmd_with_rbenv} #{current_path}/bin/rails dbconsole #{rails_env}"
    end
  end

  desc "Tail log file"
  task :log, :file do |_t, args|
    on roles(:app), primary: true do
      rails_env = fetch(:rails_env)
      execute_remote_command "#{bundle_cmd_with_rbenv} tail -f #{current_path}/log/#{args[:file]}.log #{rails_env}"
    end
  end

  def execute_remote_command(command)
    port = fetch(:port) || 22
    puts "opening a console on: #{host}...."
    cmd = "ssh -l #{fetch(:deploy_user)} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
    exec cmd
  end

  def bundle_cmd_with_rbenv
    if fetch(:rbenv_ruby)
      "RBENV_VERSION=#{fetch(:rbenv_ruby)} RBENV_ROOT=#{fetch(:rbenv_path)}  #{File.join(fetch(:rbenv_path), '/bin/rbenv')} exec bundle exec"
    else
      "ruby "
    end
  end
end
