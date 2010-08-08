

module Launchr
  class Commands
    # Implements the +launchr --update+ subcommand.
    # @see Launchr::CLI
    def auto_start value
      if value
        # Set
        Log.info "Setting auto start for " + Launchr::Path.launch_daemons

        watch_path = Launchr::Config[:args][:watch_path] || Launchr::Path.watch_path
        unless watch_path
          err_msg = "Not watch path found. Please specify a watch path with --watch-path"
          Log.fatal err_msd
          raise err_msg
        end
        Launchr::Config[:watch_paths] << watch_path
      else
        # Remove
        Log.info "Removing auto start for " + Launchr::Path.launch_daemons
        Log.info "Any existing running services will remain up"
      end
      
      
      
    end
  end
end

