




module Launchr
  class Commands


    # Implements the +launchr --install+ subcommand.
    # @see Launchr::CLI
    def setup value
      # check if launchr is already installed
      # if the version is too old, then update it
      
      # copy launchr to 
      # Launchr::Path.launchr_installed_root


      launchr_root = File.expand_path "../../../", File.dirname(__FILE__)
      launchr_lib = File.expand_path "../../../lib", File.dirname(__FILE__)

      dest = Launchr::Path.launchr_installed_root
      
      raise "sorry, cant write to the same source and destination" if launchr_root == dest
      raise "sorry, cant write to a destination within the source folder" if dest =~ /^#{launchr_root}/
      
      # FileUtils.rm_rf "#{dest}"
      FileUtils.mkdir_p dest

      Log.info "Launchr is now installed and setup."
      Log.info "By default, launchr will start launchd services at user login, for user '$USER'"
      Log.info "Run: $ sudo launchr setup --at-boot"
      Log.info "to authorize launchr to start services at system boot"


      # FileUtils.cp_r Dir.glob("#{launchr_lib}/*"), dest
      # FileUtils.cp_r Dir.glob("#{launchr_root}/VERSION"), "#{dest}/launchr"
      
      # if Launchr::Config[:args][:brew]
      #   backends = Dir.glob "#{dest}/launchr/backend/*"
      #   docs = Dir.glob "#{dest}/launchr/docs*"
      #   haml4r = Dir.glob "#{dest}/launchr/mixin/haml4r*"
      #   non_brew_files = [
      #     "#{dest}/launchr/application.rb",
      #     backends - ["#{dest}/launchr/backend/ruby_cocoa.rb"],
      #     "#{dest}/launchr/cli.rb",
      #     "#{dest}/launchr/commands.rb",
      #     docs,
      #     haml4r,
      #     "#{dest}/launchr/mixin/mixlib_cli.rb",
      #     "#{dest}/launchr/mixin/script.rb",
      #     "#{dest}/launchr/mixin/table.rb",
      #   ].flatten
      #   FileUtils.rm_rf(non_brew_files)
      # 
      #   config = File.read "#{dest}/launchr/config.rb"
      #   config.gsub! /backends default_backends/,"backends default_backends :brew"
      # 
      #   File.open("#{dest}/launchr/config.rb",'w') do |o|
      #     o << config
      #   end
      # end


      

    end
  end
end

