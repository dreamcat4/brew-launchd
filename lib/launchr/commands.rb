
require 'launchr/config'
require 'launchr/service'

module Launchr
  # This objects manages all of the commands to be executed by an instance of {Launchr::Application}
  # @see Launchr::Application
  # @see Launchr::CLI
  class Commands
    PriorityOrder = []

    # To be executed once. Branches out to subroutines, and handles the order-of-execution of
    # those main subrountines.
    def run
      PriorityOrder.each do |command|
        if self.class.method_defined?(command) && ! Launchr::Config[:args][command].nil?
          self.send command, Launchr::Config[:args][command]
        end
      end

      left_to_execute = Launchr::Config[:args].keys - PriorityOrder
      Launchr::Config[:args].each do |command, value|
        if left_to_execute.include?(command) && self.class.method_defined?(command) && ! value.nil?
          self.send command, Launchr::Config[:args][command]
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
      puts "Info for launchd services..."
      puts ""
      if services.empty?
        puts "We should print the status of all services here"
      else
        cmd :info, services
      end
    end

    def clean value
      puts "Cleaning launchd services..."
      Launchr::Service.cleanup
    end

    def test value
      puts "value = #{value.inspect}"
      puts Launchr::Config.configuration.inspect
      puts ""
    end
  end
end

