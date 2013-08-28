require 'bundler/capistrano'
set :repository, "https://github.com/danielld75/parpp.git"
set :use_sudo, false
set :scm, :git
set :branch, "master"
set :ssh_options, {:forward_agent => true}
set :keep_releases, 5
set :application, "parpp"
set :deploy_to, "/var/lib/parpp"
set :deploy_via, :remote_cache
set :user, "parpp"
set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"
role :web, "piotripawel.adte.pl"
role :app, "piotripawel.adte.pl"
role :db, "piotripawel.adte.pl", :primary => true
default_run_options[:pty] = true
namespace :deploy do
	task :start, :roles => :app, :except => { :no_release => true } do
		run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
	end
	task :stop, :roles => :app, :except => { :no_release => true } do
		run "#{try_sudo} kill `cat #{unicorn_pid}`"
	end
	task :graceful_stop, :roles => :app, :except => { :no_release => true } do
		run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
	end
	task :reload, :roles => :app, :except => { :no_release => true } do
		run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
	end
	task :restart, :roles => :app, :except => { :no_release => true } do
		stop
		start
	end
end
desc "Create the configs symlinks."
task :configs_symlink do
	['database.yml', 'unicorn.rb'].each do |config|
		run "cd #{release_path} && ln -snf #{shared_path}/#{config}
		#{release_path}/config/#{config}"
	end
end
after 'deploy:update_code', 'configs_symlink'