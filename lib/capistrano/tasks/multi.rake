module Capistrano
  class FileNotFound < StandardError
  end
end

namespace :deploy do

  desc 'Choose project to deploy'
  task :set_project do

    if fetch(:project).nil?

      found_projects = {}
      nb_project = 1

      # We get all the multi in the directory
      projects = fetch(:projects).sort.to_h

      # For each projets, we set the needed configuration
      projects.each do |current_project|
        found_projects[nb_project] = current_project[0].to_s
        nb_project += 1
      end

      # If project parameter is set, we don't need to ask for it
      if ENV['project']
        set :project_num, ENV['project']
      else

        puts '================================='
        puts '| N° | PROJECT'
        puts '================================='
        found_projects.each do |number, project|
          puts '| %.2i' %number.to_s+" | #{project.to_s}"
        end

        begin
          ask(:project_num, 'number')
          fetch(:project_num)
        end while !Integer(fetch(:project_num)) ||
          Integer(fetch(:project_num)) <= 0 ||
          Integer(fetch(:project_num)) > projects.length

      end

      set :project, found_projects[fetch(:project_num).to_i]

      if fetch(:use_custom_deploy_to) && fetch(:deploy_to)
        set :deploy_to, "#{fetch(:deploy_to).to_s}/#{fetch(:project).to_s}/#{fetch(:application)}"
      end

    end

  end


  desc 'Copy files for the project'
  task :copy_files do
    current_project = fetch(:project).to_s

    on roles(:all) do
      within "#{release_path}/#{fetch(:config_dir)}/#{fetch(:stage)}/#{current_project}" do
        set :linked_files, []
        files = capture :find, '.', '-type', 'f', '|', 'cut', '-b', '3-'

        files = files.split("\n")
        files.each do |file|
          file = Pathname.new file
          execute :mkdir, '-p', release_path.join(file.dirname)
          execute :mv, file, release_path.join(file.dirname)
        end
      end

      within release_path do
        execute :rm, '-Rf', fetch(:config_dir)
      end

    end

  end

  desc 'Set server group to deploy'
  task :set_server_group do

    server_groups = fetch(:server_groups)
    if server_groups

      server_group = fetch(:projects)[fetch(:project).to_sym][:server_group]
      servers = server_groups[server_group.to_sym][:servers]

      servers.each do |ip_addr, data|
        server ip_addr, data
      end

    end
  end

  after 'deploy:set_project', 'deploy:set_server_group'
  before 'deploy:starting', 'deploy:set_project'
  before 'deploy:symlink:release', 'deploy:copy_files'


end

namespace :load do
  task :defaults do
    set :use_custom_deploy_to, true
    set :config_dir, 'config'
  end
end
