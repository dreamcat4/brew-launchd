module Launchr
  class Service
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
        when /Library\/LaunchDaemons/
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
        when /Library\/LaunchDaemons/
          # its a started user service
          @selected_plist_states << :started_user
        end
      end

    end

    def start
      if @selected_plists.empty?
        puts "#{name} - Nothing to start"
        return
      end

      if Launchr::Config[:boot] && ! Launchr.superuser?
        raise "To start a boot time service requires sudo. Use sudo start --boot"
      end

      if Launchr.superuser? && @plist_states.include?(:started_user)
        raise "This service is already started at user login. Stop the service first, or use restart --boot"
      elsif @plist_states.include?(:started_system)
        raise "This service is already started at boot. Stop the service first, or use restart --user"
      end

      if @selected_plist_states.include?(:stopped)
        launchdaemons = nil
        if Launchr::Config[:boot]
          # Log.info "chowning #{@keg.to_s} to root:wheel"
          FileUtils.chown_R("root","wheel",@keg.to_s)
          launchdaemons = "/Library/LaunchDaemons"
        else
          launchdaemons = File.expand_path("~/Library/LaunchDaemons")
        end


        @selected_plists.each_index do |i|
          if @selected_plist_states[i] == :stopped
            plist = Pathname.new(@selected_plists[i])
            plist_real = plist.realpath
            # plist_real.basename
            
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

    def launchctl action, plist
      if Launchr::Config[:boot]
        `sudo launchctl #{action} -w #{plist}`
      else
        `launchctl #{action} -w #{plist}`
      end
    end

    def keg
      # puts @plists.inspect
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

    def stop
      if @selected_plists.empty?
        puts "#{name} - Nothing to stop"
        return
      end

      if !Launchr.superuser? && @plist_states.include?(:started_system)
        raise "To stop a boot time service requires sudo. Use sudo stop --boot"
        # raise "This service is already started at boot. Stop the service first, or use restart --user"
      end

      if @selected_plist_states.include?(:started_user) || @selected_plist_states.include?(:started_system)
        launchdaemons = nil
        if Launchr::Config[:boot]
          launchdaemons = "/Library/LaunchDaemons"
        else
          launchdaemons = File.expand_path("~/Library/LaunchDaemons")
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
            # ln -sf ../../Cellar/pincaster/0.5/Library/LaunchDaemons/com.github.pincaster.plist
            # plist_real.relative_path_from(Launchr::Path.brew_launchdaemons)
            pool_link.make_symlink(plist_real.relative_path_from(Pathname.new(Launchr::Path.brew_launchdaemons)))
          end
        end

        if Launchr::Config[:boot]
          parent_user  = Etc.getpwuid(@keg.parent.stat.uid).name
          parent_group = Etc.getgrgid(@keg.parent.stat.gid).name

          # Log.info "chowning #{@keg.to_s} to #{parent_user}:#{parent_group}"
          FileUtils.chown_R(parent_user,parent_group,@keg.to_s)
        end
        
      else
        puts "#{name} - Already stopped"
      end
    end
    
    def restart
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

  end
end

