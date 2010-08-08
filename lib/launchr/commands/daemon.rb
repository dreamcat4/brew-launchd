
require 'launchr/log'

module Launchr
  class Commands

    # @see Launchr::CLI
    def daemon value
      # load configuration file

      # read the plist file
      # are all watch paths represented in the launchd watch paths?
      #  no, then re-write the plist file and restart the launchr daemon
      # that means;

      #   1. write new plist file (with a different label)
      #   2. launchctl load new label
      #      -> new service loaded
      #         3. launchctl unload old label
      #         3.b possibly re-write old label
      #         4. launchctl load old label
      #             -> old service reloaded
      #                5. launchctl unload new label

      # ok
      # 
      # 1. for each watch path
      # check the watch path exists
      # 
      # if the watch path doesnt exist...
      #   look at the relpath links for each plist
      #   in Launchr::Path.launchd_daemons
      #     for each symlink
      #     if a realpath matches a missing / deleted watch path
      #     then 
      #        a) bring that service down with launchctl
      #        b) delete the symlink from launchdaemons folder

      # modify watch_patchs configuration setting in launchr config
      #      (delete the watch path entry for the missing path)

      # 1. a there 0 watch paths remaining
      #    delete the launchr plist file
      #    delete the launchr application support folder (uninstall the copy)
      #    stop the launchr service
      
      # 1. b there are 1 or more watch paths remaining
      # re-install the launchr plist file with new watch_paths key
      # restart launchr launchd service gracefully (is this possible from launchr daemon?)


      # 2. a launchr watch path has changed?
      #       which watch_path?
      #         what file(s) have changed?
      #          dir glob each watch path
      #            check the time stamps, are there any file(s) within the skew time?
      # 
      # 2. b launchr queuedirectory has changed
      #       which queuedirectory?
      # 
      # 

      # 2.result - launchd service failed to start, stop, or restart


    end

  end
end

