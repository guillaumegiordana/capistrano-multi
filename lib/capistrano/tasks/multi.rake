module Capistrano
  class FileNotFound < StandardError
  end
end

namespace :deploy do

  desc 'Choose project to deploy'
  task :set_project do

    if fetch(:project).nil? && fetch(:projects)

      # We get all the multi in the directory
      projects = fetch(:projects).sort.to_h

      # If project parameter is set, we don't need to ask for it
      if ENV['project'] && !ENV['project'].nil? && projects.key?(ENV['project'].to_sym)
        set :project_name, ENV['project']
      else

        puts '====================='
        puts 'PROJECT'
        puts '====================='
        projects.each do |project|
          puts project[0].to_s
        end

        begin
          ask(:project_name, nil)
          fetch(:project_name)

        end while fetch(:project_name).nil? ||
          !projects.key?(fetch(:project_name).to_sym)

      end

      set :project, fetch(:project_name)

      if fetch(:use_custom_deploy_to) && fetch(:deploy_to)
        app_folder = fetch(:application).tr('-', '/')
        set :deploy_to, "#{fetch(:deploy_to).to_s}/#{fetch(:project).to_s}/#{app_folder}"
      end

    end

  end


  desc 'Copy files for the project'
  task :copy_files do
    current_project = fetch(:project).to_s

    paths = Array.new
    if current_project
      paths.push(File.path("#{release_path}/#{fetch(:config_dir)}/#{fetch(:stage)}/#{fetch(:projects_dir)}/#{current_project}"))
    end

    if fetch(:use_global_config)
      paths.push(File.path("#{release_path}/#{fetch(:config_dir)}/#{fetch(:stage)}/#{fetch(:global_config_dir)}"))
    end

    on roles(:all) do

      paths.each do |path|
        within path do
          set :linked_files, []
          files = capture :find, '.', '-type', 'f', '|', 'cut', '-b', '3-'

          files = files.split("\n")
          files.each do |file|
            file = Pathname.new file
            execute :mkdir, '-p', release_path.join(file.dirname)
            execute :mv, file, release_path.join(file.dirname)
          end
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
  after 'deploy:symlink:shared', 'deploy:copy_files'


end

namespace :load do
  task :defaults do
    set :use_custom_deploy_to, true
    set :config_dir, 'config'
    set :use_global_config, false
    set :projects_dir, ''
    set :global_config_dir, 'global'
  end
end
