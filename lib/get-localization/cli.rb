require 'get-localization'
require 'rubygems'
require 'thor'
require 'highline'

$terminal = HighLine.new

module GetLocalization
  class CLI < Thor
    include Thor::Actions

    desc "status", "Show some information about the current project and translation progress"
    method_option :project, :default => ".getlocalization.yml", :desc => "Location of the YAML file with settings for the current project"
    def status
      project = Project.new(options[:project])
      ensure_credentials(project)

      info = project.translation_info

      info.each do |master_file, lang_hash|
        say "\nMaster File: #{master_file} => #{lang_hash['master'][:local_path]}"
        lang_hash.delete('master')
        lang_hash.each do |lang, hash|
          if hash[:server] and hash[:local_path]
            info "  #{lang}: #{hash[:progress]}% translated => #{hash[:local_path]}"
          elsif hash[:server]
            warn "  #{lang}: #{hash[:progress]}% translated but not defined in the YAML file"
          else
            error "  #{lang}: Defined in YAML file (#{hash[:local_path]}) but not part of the project according to Get Localization!"
          end
        end
      end

      # info.delete_if {|key, value| project.files.has_key? key }
      # say ""
      # info.each do |master_file, _|
      #   warn "#{master_file} is defined at Get Localization but not included in the YAML project file!"
      # end
    end

    desc "pull", "Download the latest translations from Get Localization"
    method_option :project, :default => ".getlocalization.yml", :desc => "Location of the YAML file with settings for the current project"
    def pull
      project = Project.new(options[:project])
      ensure_credentials(project)

      # Download anything that's present at the server and defined in the YAML.
      # Warn about anything else.

      info = project.translation_info
      info.each do |master_file, lang_hash|
        say "\nProcessing master file #{master_file}"
        lang_hash.delete('master')
        lang_hash.each do |lang, hash|
          if hash[:server] and hash[:local_path]
            say "Downloading #{hash[:local_path]} "
            project.download(master_file, lang)
            info "OK"
          elsif hash[:server]
            warn "  #{lang}: #{hash[:progress]}% translated but not defined in the YAML file"
          else
            error "  #{lang}: Defined in YAML file (#{hash[:local_path]}) but not part of the project according to Get Localization!"
          end
        end
      end

      info "\nLatest translations have been downloaded, but not checked in. Please look over\nand commit any changes."
    end

    desc "push", "Upload the latest master files to Get Localization"
    method_option :project, :default => ".getlocalization.yml", :desc => "Location of the YAML file with settings for the current project"
    def push
      project = Project.new(options[:project])
      ensure_credentials(project)

      project.files.each do |master_file, hash|
        say "Uploading #{hash['master']} "
        if project.upload(master_file)
          info "OK"
        else
          error "ERROR"
          error project.last_error
        end
      end
    end

    no_tasks do
      def ensure_credentials(project)
        return if project.has_credentials?
        unless project.has_username?
          project.username = $terminal.ask("Username: ")
        end
        unless project.has_password?
          project.password = $terminal.ask("Password: ") {|q| q.echo = false}
        end
      end

      def info(name, message=nil)
        say_with_status(name, message, :green)
      end

      def warn(name, message=nil)
        say_with_status(name, message, :yellow)
      end

      def error(name, message=nil)
        $stdout = $stderr
        say_with_status(name, message, :red)
      ensure
        $stdout = STDOUT
      end

      def say_with_status(name, message=nil, color=nil)
        if message
          say_status name, message, color
        elsif name
          say name, color
        end
      end
    end
  end
end
