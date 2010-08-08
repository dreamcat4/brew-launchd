
require 'launchr/service'

module Launchr
  # This objects manages all of the commands to be executed by an instance of {Launchr::Application}
  # @see Launchr::Application
  # @see Launchr::CLI
  class Commands
    PriorityOrder = []

    def preflight_checks
      unless Launchr::Path.homebrew_prefix
        puts "Preflight checks..."
        raise "No homebrew prefix was found"
      end
    end

    # To be executed once. Branches out to subroutines, and handles the order-of-execution of
    # those main subrountines.
    def run
      preflight_checks

      PriorityOrder.each do |command|
        if self.class.method_defined?(command) && ! Launchr.config[:args][command].nil?
          self.send command, Launchr.config[:args][command]
        end
      end

      left_to_execute = Launchr.config[:args].keys - PriorityOrder
      Launchr.config[:args].each do |command, value|
        if left_to_execute.include?(command) && self.class.method_defined?(command) && ! value.nil?
          self.send command, Launchr.config[:args][command]
        end
      end
    end

    def cmd cmd, services
      Launchr::Service.cleanup
      services.each do |svc|
        service = Launchr::Service.find(svc)
        service.send(cmd)
      end
    end

    def start services
      puts "Starting launchd services..."
      cmd :start, services
    end
      
    def stop services
      puts "Stopping launchd services..."
      cmd :stop, services
    end
      
    def restart services
      puts "Restarting launchd services..."
      cmd :restart, services
    end

    def info services
      Launchr::Service.cleanup
      
      if services.empty?

        level = Launchr.config[:boot] ? "--boot" : "--user"
        puts "Launchd default is #{level}"
        puts ""

        services = Launchr::Service.find_all
        if services.empty?
          puts "No launchd services installed"
        else
          puts Launchr::Service.header
        end
        services.each do |svc|
          svc.send :info
        end
      else
        puts Launchr::Service.header
        services.map! do |svc|
          Launchr::Service.find(svc)
        end
        services.uniq!

        services.each do |svc|
          svc.send :info
        end
      end
      puts ""
    end

    def clean value
      puts "Cleaning launchd services..."
      Launchr::Service.cleanup
      puts "Done."
    end

    def default value
      if Launchr.config[:args][:boot]
        puts "Setting default to --boot"
        Launchr::Path.launchr_default_boot.touch
        Launchr::Path.chown_down Launchr::Path.launchr_default_boot
        Launchr.config[:boot] = true
      else
        puts "Setting default to --user"
        if Launchr::Path.launchr_default_boot.exist?
          Launchr::Path.launchr_default_boot.unlink
        end
        Launchr.config[:boot] = nil
      end
    end

    def version value
      puts "Launchr (for Brew) v#{Launchr.version}"
    end
  end
end

