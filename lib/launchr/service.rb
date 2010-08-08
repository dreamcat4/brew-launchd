module Launchr
  class Service
    class << self

      def launchctl action, plist
        `launchctl #{action} -w #{plist}`
      end

      def sudo_launchctl action, plist
        if Launchr.superuser?
          `sudo launchctl #{action} -w #{plist}`
        else
          raise "Insufficient permissions, cant sudo"
        end
      end

      def cleanup
        # 1.
        # scan through 2 launchdaemons folders and readlink
        # paths matching homebrew_prefix, which ! exist?
        # these should be unloaded by domain name
        # delete broken link afterwards

        # should warn if no sudo, that to rerun with sudo

        # 2.
        # scan through brew_launchdaemons folder those files
        # which are not up (pointing to cellar)
        # if they exist in either the 2 launchdaemons folders...
        # they should be brought down with launchctl and unlinked too

        unless Launchr::Path.homebrew_prefix
          raise "No homebrew prefix was found"
        end
        prefix = Launchr::Path.homebrew_prefix
        brew_plists = Dir.glob("#{prefix}/Library/LaunchDaemons/*")

        brew_plists.map! { |p| Pathname.new(p).readlink.to_s }
        down_brew_plists = brew_plists.select { |p| p.include? Launchr::Path.homebrew_prefix }

        uld_plists = Dir.glob("#{Launchr::Path.user_launchdaemons}/*")
        brew_uld_plists = uld_plists.select { |p| Pathname.new(p).realpath.to_s.include? Launchr::Path.homebrew_prefix }

        missing_brew_uld_plists = brew_uld_plists.select do |p|
          rp = Pathname.new(p).realpath
          !rp.exist? || down_brew_plists.include?(rp.to_s)
        end

        missing_brew_uld_plists.each do |plist|
          label = File.basename(plist,".plist")
          # launchctl :list, label
          # if exit code is zero, then stop the service
          launchctl :stop, label
          # or ignore the return code

          # delete the broken link
          Pathname.new(plist).unlink
        end

        sld_plists = Dir.glob("#{Launchr::Path.boot_launchdaemons}/*")
        brew_sld_plists = sld_plists.select { |p| Pathname.new(p).realpath.to_s.include? Launchr::Path.homebrew_prefix }

        missing_brew_sld_plists = brew_sld_plists.select do |p|
          rp = Pathname.new(p).realpath
          !rp.exist? || down_brew_plists.include?(rp.to_s)
        end

        if !missing_brew_sld_plists.empty? && !Launchr.superuser?
          puts "Launchctl database was left in an inconsistent state"
          puts "This happens when a formula is uninstalled, but the"
          puts "service is not stopped."
          puts "Run `sudo launchr info` to cleanup"
        else
          missing_brew_sld_plists.each do |plist|
            label = File.basename(plist,".plist")
            # launchctl :list, label
            # if exit code is zero, then stop the service
            launchctl :stop, label
            # or ignore the return code

            # delete the broken link
            Pathname.new(plist).unlink
          end
        end
      end
      
      def find svc
        unless Launchr::Path.homebrew_prefix
          raise "No homebrew prefix was found"
        end

        prefix = Launchr::Path.homebrew_prefix
        formula_name = nil
        formula_plists = []
        selected_plists = []

        # puts "prefix = #{prefix.inspect}"

        installed_plists = Dir.glob("#{prefix}/Library/LaunchDaemons/*")
        # installed_plists_realpaths = installed_plists.map { |p| Pathname.new(p).realpath.to_s }

        case svc
        when /^[^\.]+$/
          # its not a label or filename
          # so should be a formula name, or formula alias name

          if File.exists?("#{prefix}/Library/Aliases/#{svc}")
            # its an alias
            alias_realpath = Pathname.new("#{prefix}/Library/Aliases/#{svc}").realpath
            formula_name = alias_realpath.basename(".rb").to_s
          end

          if File.exists?("#{prefix}/Library/Formula/#{svc}.rb")
            # its a formula name
            # puts "#{prefix}/Library/Formula/#{svc}.rb"
            # Dir.glob "#{Launchr::Path.homebrew_prefix}/Cellar/#{svc}/"
            formula_name = svc
          end

          if formula_name
            # wrong
            # formula_plists << installed_plists_realpaths.select { |p| p.include? "Cellar\/#{formula_name}" }
            # should_be
            # formula_plists << installed_plists.select { |p| p.realpath.to_s.include? "Cellar\/#{formula_name}" }
            formula_plists = installed_plists.select { |p| Pathname.new(p).realpath.to_s.include? "Cellar\/#{formula_name}" }
            selected_plists = formula_plists.dup
          end

        else
          # lookup the label filename
          label = File.basename(svc,".plist")
          plist_link = "#{prefix}/Library/LaunchDaemons/#{label}.plist"
          if File.exists?(plist_link)
            # its a label
            plist_realpath = Pathname.new(plist_link).realpath
            # if the plist was started, it will point to the target

            formula_name = plist_realpath.to_s.gsub(/^.*Cellar\/|\/.*$/,"")
            # wrong
            # formula_plists << installed_plists_realpaths.select { |p| p.include? "Cellar\/#{formula_name}" }
            # should_be
            # formula_plists << installed_plists.select { |p| p.realpath.to_s.include? "Cellar\/#{formula_name}" }
            formula_plists = installed_plists.select { |p| Pathname.new(p).realpath.to_s.include? "Cellar\/#{formula_name}" }
            selected_plists << plist_realpath.to_s
          end
        end

        unless formula_name
          raise "Service #{svc} not found"
        end

        Launchr::Service.new(formula_name, formula_plists, selected_plists)
      end
      
    end

    attr_accessor :name, :plists, :plist_states, :selected_plists

    def initialize formula_name, formula_plists, selected_plists
      @name = formula_name
      @plists = formula_plists
      @selected_plists = selected_plists
      @plist_states = []
      @selected_plist_states = []
      keg
      get_service_info
    end

    def get_service_info

      plists.each do |plist|
        # puts plist.inspect
        plist_readlink = Pathname.new(plist).readlink
        case plist_readlink
        when /Cellar/
          # its a stopped service
          @plist_states << :stopped
        when /^\/Library\/LaunchDaemons/
          # its a started system service
          @plist_states << :started_system
        when /Library\/LaunchAgents/
          # its a started user service
          @plist_states << :started_user
        end
      end

      selected_plists.each do |plist|
        # puts plist.inspect
        plist_readlink = Pathname.new(plist).readlink
        case plist_readlink
        when /Cellar/
          # its a stopped service
          @selected_plist_states << :stopped
        when /^\/Library\/LaunchDaemons/
          # its a started system service
          @selected_plist_states << :started_system
        when /Library\/LaunchAgents/
          # its a started user service
          @selected_plist_states << :started_user
        end
      end

    end

    def launchctl action, plist
      if Launchr.superuser?
        `sudo launchctl #{action} -w #{plist}`
      else
        # puts plist
        `launchctl #{action} -w #{plist}`
      end
    end

    def keg
      unless @keg
        if @plists[0]
          keg_relative = Pathname.new(Pathname.new(@plists[0]).realpath.to_s.gsub(/\/Library\/LaunchDaemons.*/,""))
          @keg = keg_relative.expand_path(Pathname.new(@plists[0]).dirname)
        else
          @keg ||= false
        end
      end
      @keg
    end

    def start
      if @selected_plists.empty?
        puts "#{name} - Nothing to start"
        return
      end

      # if Launchr::Config[:boot] && ! Launchr.superuser?
      #   raise "To start a boot time service requires sudo. Use sudo start --boot"
      # end

      if Launchr.superuser? && @plist_states.include?(:started_user)
        raise "This service is already started at user login. Stop the service first, or use restart --boot"
      elsif @plist_states.include?(:started_system)
        raise "This service is already started at boot. Stop the service first, or use restart --user"
      end

      if @selected_plist_states.include?(:stopped)
        launchdaemons = nil
        if Launchr::Config[:boot]
          # puts "chowning #{@keg.to_s} to root:wheel"
          FileUtils.chown_R("root","wheel",@keg.to_s)
          launchdaemons = Launchr::Path.boot_launchdaemons
        else
          launchdaemons = Launchr::Path.user_launchdaemons
        end


        @selected_plists.each_index do |i|
          if @selected_plist_states[i] == :stopped
            plist = Pathname.new(@selected_plists[i])
            plist_real = plist.realpath
            
            target = Pathname.new("#{launchdaemons}/#{plist_real.basename.to_s}")
            target.make_symlink(plist_real)

            plist.unlink
            plist.make_symlink(target)

            launchctl :load, target
          end
        end
      else
        puts "#{name} - Already started"
      end
    end

    def stop
      if @selected_plists.empty?
        puts "#{name} - Nothing to stop"
        return
      end

      if !Launchr.superuser? && @plist_states.include?(:started_system)
        raise "To stop a boot time service requires sudo. Use sudo stop --boot"
      end

      if @selected_plist_states.include?(:started_user) || @selected_plist_states.include?(:started_system)
        launchdaemons = nil
        if Launchr::Config[:boot]
          launchdaemons = Launchr::Path.boot_launchdaemons
        else
          launchdaemons = Launchr::Path.user_launchdaemons
        end
      
      
        @selected_plists.each_index do |i|
          if @selected_plist_states[i] == :started_user || @selected_plist_states[i] == :started_system
            plist = Pathname.new(@selected_plists[i])
            plist_real = plist.realpath
            # puts plist.readlink.dirname.to_s.inspect
            launchdaemons = plist.readlink.dirname.to_s
            
            target = Pathname.new("#{launchdaemons}/#{plist_real.basename.to_s}")
            launchctl :unload, target
            # catch the return code. cancel if unload failed
            target.unlink
            
            pool_link = Pathname.new("#{Launchr::Path.brew_launchdaemons}/#{plist_real.basename.to_s}")
            pool_link.unlink
            pool_link.make_symlink(plist_real.relative_path_from(Pathname.new(Launchr::Path.brew_launchdaemons)))
          end
        end

        if Launchr::Config[:boot]
          parent_user  = Etc.getpwuid(@keg.parent.stat.uid).name
          parent_group = Etc.getgrgid(@keg.parent.stat.gid).name

          # puts "chowning #{@keg.to_s} to #{parent_user}:#{parent_group}"
          FileUtils.chown_R(parent_user,parent_group,@keg.to_s)
        end
        
      else
        puts "#{name} - Already stopped"
      end
    end
    
    def restart
      # perhaps something is wrong here
      stop
      start
    end

    def labels
      @labels ||= @plists.map { |p| File.basename(p,".plist").to_s }
    end

    def to_s
      name
    end

    def statuslines
      @statuslines ||= @plist_states.map do |state|
        case state
        when :started_system
          "Started"
        when :started_user
          "Started"
        when :stopped
          "Stopped"
        end
      end
    end

    def inspect
      out = []
      # service installed?
      out << "Service: #{name}"
      plists.each_index do |i|
        out << " #{labels[i]} " 
        out << " "*20+statuslines[i]
      end
      if plists.empty?
        out << " Installed: NO" || "Active: NO"
      end
      out.join("\n")
    end
    
    def info
      puts inspect
    end

  end
end

