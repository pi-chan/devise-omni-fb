require 'capistrano_colors'

set :rails_env, "production"
server "vps", :web, :app, :db, :primary => true

# General
set :application, "devise-omni-fb"
set :keep_releases, 5

# Repository
set :repository,  "git://github.com/xoyip/devise-omni-fb.git"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache
set :scm_verbose, true

# db-tasks
set :db_local_clean, true

# Bundler
require 'bundler/capistrano'
set :bundle_flags, "--deployment --binstubs"
set :bundle_without, [:test, :development, :deploy]

# Server Setting
set :user, "hiromasa"
set :use_sudo, false
ssh_options[:forward_agent] = true
ssh_options[:keys] = ["/Users/hiromasa/.ssh/sakuravps-hiromasa"]
set :deploy_to, "/home/hiromasa/apps/#{application}"

load 'deploy/assets'
after :deploy, "deploy:migrate"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:clean && 
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile
      CMD
    end
  end

  namespace :bang_method do
    task :db_reset do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} db:migrate:reset
      CMD
    end
  end

end

