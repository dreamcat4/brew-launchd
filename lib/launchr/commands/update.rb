

module Launchr
  class Commands
    # Implements the +launchr --update+ subcommand.
    # @see Launchr::CLI
    def update value
      puts "updating launchr"

      # look in the watch dir
      # see which files are missing
      # create symlink for new file(s)
      
      # start the launchd service
      # launchctl load -w etc

    end
  end
end

