# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'test-app'
set :repo_url, 'git@github.com:Animeshjain2405/test-app.git'
set :deploy_to,  "/ebs/apps/#{application}"
set :applicationdir,  "/ebs/apps/#{application}"

set :use_sudo, false
set :scm, :git
set :keep_releases, 2
set :rails_env, "production"
set :precompile_only_if_changed, true


set :deploy_to, applicationdir
set :deploy_via, :export

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end

# additional settings
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5



    # task :reindex do
    #   run "/bin/chmod a+rwx #{sphinx_pid}"
    # end
