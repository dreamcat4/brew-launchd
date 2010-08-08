

module Launchr
  class Commands
    # Implements the +launchr --update+ subcommand.
    # @see Launchr::CLI
    def lock_sudo value
      if value
        Log.info "locking sudo"
      else
        Log.info "unlocking sudo"
      end
    end

    def check_sudo_lock
      puts "checking sudo lock..."
      if Launchr::Config[:lock_sudo] && ! Launchr.superuser?
        err_msg = "Sudo is locked"
        Log.fatal err_msg
        raise err_msg
      end
    end
  end
end

