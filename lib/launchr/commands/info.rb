
require 'launchr/log'
require 'launchr/service_finder'

module Launchr
  class Commands

    def info services
      Log.info "Info for launchd services..."
      puts ""
      sf = Launchr::ServiceFinder.new
      services.each do |svc|
        service = sf.find(svc)
        puts service.inspect
        puts ""
      end

    end

  end
end

