
require 'launchr/config'
# require 'fileutils'

# require 'launchr/commands/auto_start'
# require 'launchr/commands/lock_sudo'

require 'launchr/commands/setup'
require 'launchr/commands/start_stop_restart'
require 'launchr/commands/log'
require 'launchr/commands/info'
require 'launchr/commands/daemon'
require 'launchr/commands/test'
require 'launchr/commands/update'
require 'launchr/commands/remove'

module Launchr
  # This objects manages all of the commands to be executed by an instance of {Launchr::Application}
  # @see Launchr::Application
  # @see Launchr::CLI
  class Commands
    # CommandsSudoAffects = [:auto_start,:start,:stop,:restart]
    # CommandsSudoAffects = [:start,:stop,:restart]

    # PriorityOrder = [:install,:update]
    PriorityOrder = [:log_level,:log,:lock_sudo,:auto_start]

    # To be executed once. Branches out to subroutines, and handles the order-of-execution of
    # those main subrountines.
    def run
      # Launchr::Config[:args].each do |command, value|
      #   if CommandsSudoAffects.include?(command) && ! value.nil?
      #     self.send :check_sudo_lock
      #     break
      #   end
      # end

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
  end
end

