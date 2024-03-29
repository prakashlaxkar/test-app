# config valid only for Capistrano 3.1
require 'bundler/capistrano'

set :application, 'test-app'
set :repository, 'git@github.com:Animeshjain2405/test-app.git'
set :deploy_to,  "/ebs/apps/test-app"
set :applicationdir,  "/ebs/apps/test-app"
set :user, "ubuntu"

set :use_sudo, false
set :scm, :git
set :keep_releases, 2
set :rails_env, "production"
set :precompile_only_if_changed, true


# deploy config
set :deploy_to, "/ebs/apps/test-app"
set :deploy_via, :export

# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
default_run_options[:shell] = '/bin/bash --login'

# ssh_options[:keys] = ["/home/animesh/.ssh/animesh.pem"]

ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys

after "deploy:update_code", "deploy:copy_configs"

task :prod do
  set :domain, "54.169.2.142"
  set :repository, "git@github.com:Animeshjain2405/test-app.git"
  set :local_repository, "git@github.com:Animeshjain2405/test-app.git"
  set :branch, "master"
  set :scm_verbose, true
  server "54.169.2.142", :app, :web, :db, :primary => true
  set :deploy_env, "prod"
  # deploy config

  "deploy"

end

namespace :deploy do

  task :copy_configs, :roles => :app do
    run "cp #{release_path}/../../shared/database.yml #{release_path}/config/database.yml"
    # run "cp #{release_path}/config/initializers/global.rb.#{deploy_env} #{release_path}/config/initializers/global.rb"
    run "cp #{release_path}/config/environment.rb.#{deploy_env} #{release_path}/config/environment.rb"
    # run "cp #{release_path}/config/sphinx.yml.#{deploy_env} #{release_path}/config/sphinx.yml"
    # run "cp #{release_path}/public/robots.txt.#{deploy_env} #{release_path}/public/robots.txt"
  end

  task :migrate, :roles => :app do
    run "cd #{release_path} && bundle exec rake db:migrate"
  end

  task :link_shared_directories do
    run "ln -s #{shared_path}/uploads #{release_path}/uploads"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do

    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    # if deploy_env=="qa"
    #   run "#{try_sudo} mkdir -p #{release_path}/tmp/cache"
    #   run "#{try_sudo} chown -R nobody:nobody #{release_path}/tmp/cache"
    #   run "#{try_sudo} mkdir -p #{release_path}/tmp/views"
    #   run "#{try_sudo} chown -R nobody:nobody #{release_path}/tmp/views"
    # end
    if deploy_env == 'prod'
      tag_name = Time.now.strftime("deploy_%Y_%m_%d_%H_%M")

      system "git tag -a -m 'Deployment on prod' #{tag_name}"

      system "git push origin #{tag_name}"
      if $? != 0
        raise "Pushing tag to origin failed"
      end
    end
  end


  #task :pipeline_precompile do
  #  run "cd #{release_path}; /usr/local/rvm/gems/ruby-1.9.2-p290/bin/bundle install"
  #  run "cd #{release_path}; /usr/local/rvm/gems/ruby-1.9.2-p290/bin/bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile"
  #end
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      logger.info "Skipping asset pre-compilation because there were no asset changes"
    end
  end
end

after "deploy:update", "deploy:migrate", "deploy:cleanup"
after "deploy:update_code", "deploy:link_shared_directories"
