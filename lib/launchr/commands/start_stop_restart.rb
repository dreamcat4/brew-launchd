
require 'launchr/log'
require 'launchr/service_finder'

module Launchr
  class Commands


    # Start launchd service(s)
    # @see Launchr::CLI
    def start services
      # resolve_watch_paths
      Log.info "Starting launchd services..."
      sf = Launchr::ServiceFinder.new
      services.each do |svc|
        service = sf.find(svc)
        service.start
        # service.up?
        # service.info
        # service.installed?
        # sf.result
        # plist_filenames = sf.results.filenames
      end
    end
      
    # Stop launchd service(s)
    # @see Launchr::CLI
    def stop services
      Log.info "Stopping launchd services..."
      sf = Launchr::ServiceFinder.new
      services.each do |svc|
        service = sf.find(svc)
        service.stop
      end
    end
      
      # Restart launchd service(s)
      # @see Launchr::CLI
      def restart services
        Log.info "Restarting launchd services..."
        sf = Launchr::ServiceFinder.new
        services.each do |svc|
          service = sf.find(svc)
          service.restart
          # is the service name in the watch folder?
          # is the service name a brew formula name?
          # match string
        end
      end
      
      # service.up?
      # service.info
      # service.installed?
      
  end
end

