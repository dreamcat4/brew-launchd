
require 'launchr/log'

module Launchr
  class Commands

    # @see Launchr::CLI
    def log_level level
      Launchr::Log.level = level.downcase.to_sym
    end

    # @see Launchr::CLI
    def log logger_args
      logger_args.map! do |arg|
        if arg.to_i > 0
          arg.to_i
        else
          arg
        end
      end
      puts "Option to set the Ruby Logger format ?"
      puts "logger args: #{logger_args.inspect}"
      # Launchr::Log.init(*logger_args)
    end
  end
end

