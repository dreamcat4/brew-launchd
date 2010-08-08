
require 'launchr/extend/pathname'
require 'launchr/path'
require 'launchr/mixin/popen4'
require 'timeout'

module Launchr
  class Service
    class << self
      def sudo_launchctl_exec *args
        popen  "/usr/bin/sudo", "/bin/launchctl", *args
      end

      def launchctl_exec *args
        popen  "/bin/launchctl", *args
      end

      def popen cmd, *args
        stdin_str = nil

        pid, stdin, stdout, stderr = ::Launchr::Popen4::popen4 [cmd, *args]

          stdin.puts stdin_str if stdin_str
          stdin.close

          ignored, status = [nil,nil]

          begin
            Timeout::timeout(Launchr.launchctl_timeout) do
              ignored, status = Process::waitpid2 pid
            end
          rescue Timeout::Error => exc
            puts "#{exc.message}, killing pid #{pid}"
            Process::kill('TERM', pid)
            # Process::kill('HUP', pid)
            ignored, status = Process::waitpid2 pid
          end

          stdout_result = stdout.read.strip
          stderr_result = stderr.read.strip

        return { :cmd => cmd, :status => status, :stdout => stdout_result, :stderr => stderr_result }
      end

      def launchctl action, plist
        job = plist
        case job
        when String, Pathname
        when LaunchdJob
        else
        end
        
        result = launchctl_exec action.to_s, "-w", plist.to_s
        puts result[:stdout] unless result[:stdout].empty?
        puts result[:stderr] unless result[:stderr].empty?
      end

      def sudo_launchctl action, plist
        if Launchr.superuser?
          result = sudo_launchctl_exec action.to_s, "-w", plist.to_s
          puts result[:stdout] unless result[:stdout].empty?
          puts result[:stderr] unless result[:stderr].empty?
        else
          raise "Insufficient permissions, cant sudo"
        end
      end

      def fix_broken_symlinks
        brew_plists = Pathname.glob(Launchr::Path.homebrew_prefix+"Library/LaunchDaemons/*")
        broken_plists = brew_plists.select { |p| p.readable? == false }

        installed_plists_realpaths = Pathname.glob(Launchr::Path.homebrew_prefix+"Cellar/**/Library/LaunchDaemons/*.plist")

        installed_plists_realpaths.each do |real|
          pool_link = Launchr::Path.homebrew_prefix+"Library/LaunchDaemons"+real.basename
          if !pool_link.exist?
            pool_link.make_symlink(real.relative_path_from(Launchr::Path.brew_launchdaemons))
          end
        end

        if !broken_plists.empty?
          
          broken_plists.each do |broken|
            match = installed_plists_realpaths.select { |r| r.include?(broken.basename) }.first
            target = nil
            case broken.readlink
            when /Cellar/
              broken.unlink

            when /^\/Library\/LaunchDaemons/
              broken.unlink
              if match
                if !Launchr.superuser?
                  puts "Launchctl database was left in an inconsistent state"
                  puts "This happens when a formula is uninstalled, but the"
                  puts "service was not stopped."
                  puts "Run `sudo launchr clean` to cleanup"
                else
                  target = Launchr::Path.boot_launchdaemons + broken.basename
                  target.make_symlink(match)
                  launchctl :stop, target.basename(".plist")
                  target.unlink
                  broken.make_symlink(match)
                end
              end
            when /Library\/LaunchAgents/
              broken.unlink
              if match
                target = Launchr::Path.user_launchdaemons + broken.basename
                target.make_symlink(match)
                launchctl :stop, target.basename(".plist")
                target.unlink
                broken.make_symlink(match)
              end
            end
          end
        end
      end

      def clean_plists_in apple_launchdaemons
        # scan through the homebrew LaunchDaemons folder and readlink (read the links if a symlink)
        # where the 1st level symlink points to determines the service status (up/down, running etc)
        brew_plists = Pathname.glob(Launchr::Path.homebrew_prefix+"Library/LaunchDaemons/*")
        brew_plists.map! { |p| p.readlink }

        # the services associated to these plists are installed, but should be in the down state
        # as they arent symlinked into the Apple LaunchDaemons folder
        down_brew_plists = brew_plists.select { |p| p.include? Launchr::Path.homebrew_prefix }

        # scan through the Apple LaunchDaemons folder and for all plists check their real path (final destination symlink)
        # select any plist links which point to locations in the brew tree. These should be installed and running brew services
        brew_launchdaemons_plists = apple_launchdaemons.children.select { |p| p.realpath.include? Launchr::Path.homebrew_prefix }

        # sub select (select again) any plist links which are found to be a mismatch
        # either they are not installed anymore (rm -rf'd without stopping the service)
        # and/or were resinstalled again so their service state is no longer matching
        # and reflecting the entries in the launchd database (service loaded/unloaded)
        missing_brew_launchdaemons_plists = brew_launchdaemons_plists.select do |plist|
          !plist.realpath.exist? || down_brew_plists.include?(plist.realpath)
        end

        if !missing_brew_launchdaemons_plists.empty?
          # if there are broken services at boot level, it requires root permissions
          # to fix the issue. We can detect these, and ask to re-run as root
          if !Launchr.superuser? && apple_launchdaemons == Launchr::Path.boot_launchdaemons
            puts "Launchctl database was left in an inconsistent state"
            puts "This happens when a formula is uninstalled, but the"
            puts "service was not stopped."
            puts "Run `sudo launchr clean` to cleanup"
          else
            # repair the launchctl service status and remove the symlink
            # from Apple's LaunchDaemons folder (we still keep a link in brew_launchdaemons)
            missing_brew_launchdaemons_plists.each do |plist|
              label = plist.basename(".plist")
              # launchctl :list, label; if exit code is zero, then launchctl stop label
              launchctl :stop, label # brew doesnt ignore the return code
              plist.unlink # delete broken symlink
            end
          end
        end
      end

      # Clean any inconcistencies between homebrew and launchctl launcd database
      # This can happen if formula were uninstalled with 'rm -rf'
      def cleanup
        fix_broken_symlinks
        clean_plists_in Launchr::Path.user_launchdaemons
        clean_plists_in Launchr::Path.boot_launchdaemons
      end

      def find_all
        prefix = Launchr::Path.homebrew_prefix
        installed_plists = Pathname.glob(prefix+"Library/LaunchDaemons/*")

        formula_names = installed_plists.map do |plist|
          plist.realpath.to_s.gsub(/^.*Cellar\/|\/.*$/,"")
        end
        formula_names.uniq!

        services = formula_names.map do |formula|
          find(formula)
        end

        services
      end

      # Resolve a service name to plist files, and create a new brew service object
      # A service name can be a formula name, a formula alias, or plist filename / label
      def find svc
        formula_name = nil
        jobs = []

        prefix = Launchr::Path.homebrew_prefix
        installed_plists = Pathname.glob(prefix+"Library/LaunchDaemons/*")

        case svc
        when /^[^\.]+$/
          # should be a formula name, or formula alias name

          if (prefix+"Library/Aliases/#{svc}").exist?
            # its an alias
            alias_realpath = (prefix+"Library/Aliases/#{svc}").realpath
            formula_name = alias_realpath.basename(".rb").to_s
          end

          if (prefix+"Library/Formula/#{svc}.rb").exist?
            # its a formula name
            formula_name = svc
          end

          if formula_name
            formula_plists = installed_plists.select { |p| p.realpath.include? "Cellar\/#{formula_name}" }

            jobs = formula_plists.map do |p| 
              LaunchdJob.new :plist => p, :selected => true
            end
          end

        else
          # should be a launchd job label or plist filename
          label = File.basename(svc,".plist")
          plist_link = prefix+"Library/LaunchDaemons/#{label}.plist"

          if plist_link.exist?
            formula_name = plist_link.realpath.to_s.gsub(/^.*Cellar\/|\/.*$/,"")
            formula_plists = installed_plists.select { |p| p.realpath.include? "Cellar\/#{formula_name}" }
            
            jobs = formula_plists.map do |p| 
              selected = nil
              (p == plist_link) ? selected = true : selected = false
              LaunchdJob.new :plist => p, :selected => selected
            end
            
          end
        end

        if formula_name
          Launchr::Service.new(formula_name, jobs)
        else
          # svc could be a valid service identifier, but just not installed yet. would
          # have to grep inside all the Formula files for "launchd_plist <job_label>" definitions
          # in order to figure that out. an expensive operation (but very cacheable)
          puts "Couldnt find any installed service matching \"#{svc}\" (no matches)"
          raise "Service #{svc} not found"
        end
      end
      
    end

    class LaunchdJob
      attr_accessor :label, :plist, :selected
      attr_accessor :level

      def plist= plist
        @plist = plist
        @label = plist.basename(".plist")
      end

      def level
        if @plist
          case @plist.readlink
          when /Cellar/
            @level = nil   # stopped service
          when /^\/Library\/LaunchDaemons/
            @level = :boot # started system service
          when /Library\/LaunchAgents/
            @level = :user # started user service
          end
        else
          @level = nil
        end
        @level
      end


      def started?
        !! level
      end

      def initialize *args, &blk
        case args.first
        when Hash
          opts = args.first
          opts.each do |key, value|
            self.send "#{key}=".to_sym, value
          end
        else
          raise "Unrecognized first argument: #{args.first.inspect}"
        end
      end
    end

    def hash
      @name.hash
    end

    def eql? other
      @name = other.name
    end

    attr_accessor :name, :jobs
    attr_accessor :plists, :plist_states, :selected_plists

    def initialize formula_name, jobs
      @name = formula_name
      @jobs = jobs
      @keg  = keg
    end

    def launchctl action, plist
      self.class.launchctl action, plist
    end

    def keg
      unless @keg
        @keg = false
        @jobs.each do |job|
          if job.plist && job.plist.readable?
            keg_relative = Pathname.new(job.plist.realpath.to_s.gsub(/\/Library\/LaunchDaemons.*/,""))
            @keg = keg_relative.expand_path(job.plist)
            break
          end
        end
      else
        @keg ||= false
      end
      @keg
    end
    
    def selected_jobs
      @jobs.select { |job| job.selected == true }
    end

    def selected_stopped_jobs
      @jobs.select { |job| job.selected == true && ! job.started? }
    end

    def start
      if selected_jobs.empty?
        puts "#{name} - Nothing to start"
        return
      end

      if Launchr.config[:boot] && ! Launchr.superuser?
        raise "To start a boot time service requires sudo. Use sudo start --boot"
      end

      launchdaemons = nil
      unless selected_stopped_jobs.empty?
        if Launchr.config[:boot]
          puts "chowning #{@keg} to root:wheel"
          @keg.chown_R "root", "wheel"
          launchdaemons = Launchr::Path.boot_launchdaemons
        else
          launchdaemons = Launchr::Path.user_launchdaemons
        end
      end

      selected_jobs.each do |job|
        if Launchr.superuser? && job.level == :user
          raise "#{job.label} is already started at user login. Stop the service first, or use restart --boot"
        elsif job.level == :boot
          raise "#{job.label} is already started at boot. Stop the service first, or use restart --user"
        end
        
        if !job.started?
          target = launchdaemons + job.plist.realpath.basename
          target.make_symlink(job.plist.realpath)

          job.plist.unlink
          job.plist.make_symlink(target)

          launchctl :load, target
        end
      end
    end

    def stop
      if selected_jobs.empty?
        puts "#{name} - Nothing to stop"
        return
      end

      selected_jobs.each do |job|
        if job.started?
          if job.level == :boot && !Launchr.superuser?
            raise "To stop a boot time service requires sudo. Use sudo stop --boot"
          end
          
          launchctl :unload, job.plist.readlink
          # catch the return code. cancel if the unload has failed

          source = job.plist.realpath
          job.plist.readlink.unlink
          job.plist.unlink
          job.plist.make_symlink(source.relative_path_from(Launchr::Path.brew_launchdaemons))
          
        end
      end

      if Launchr.superuser? && @jobs.select { |job| job.level == :boot }.empty?
        if @keg.user == "root"
          puts "chowning #{@keg} to #{@keg.parent.user}:#{@keg.parent.user}"
          @keg.chown_R @keg.parent.user, @keg.parent.group
        end
      end
    end
    
    def restart
      stop
      start
    end

    def self.header
      out = []
      out << sprintf("%-20.20s %-30.30s %-10.10s %-20.20s", "Service", "Launchd job", "Status", "Level")
      out << sprintf("%-20.20s %-30.30s %-10.10s %-20.20s", "-------", "-----------", "------", "-----")
      # out << sprintf("%-20.20s %-30.30s %-10.10s %-20.20s", "=======", "===========", "======", "=====")
      out.join("\n")
    end

    def printline
      out = []
      jobs.each do |job|
        s = ""
        l = ""
        case job.level
        when :boot
          s << "Started"
          l << "System Boot"
        when :user
          s << "Started"
          l << "User login"
        else
          s << "Stopped"
          # l << "n/a"
          l << "-"
        end
        if job == jobs.first
          out << sprintf("%-20.20s %-30.30s %-10.10s %-20.20s", name, job.label, s, l)
        else
          out << sprintf("%-20.20s %-30.30s %-10.10s %-20.20s",   "", job.label, s, l)
        end
      end
      out.join("\n")
    end

    def to_s
      name
    end
    
    def inspect
      self.class.header + printline
    end
    
    def info
      puts printline
    end

  end
end

