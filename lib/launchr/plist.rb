
require 'mixin/plist4r'

module Launchr
  class LaunchrPlist
    def initialize
      create
    end
    
    def write
      @plist.path Launchr::Path.launch_daemons
      @plist.save
      Launchr::Path.chown_down(@plist.filename_path)
    end

    def create
      @plist ||= Plist4r.new do
        label    Launchr.label
        filename Launchr.label + ".plist"

        program_arguments [Launchr::Path.launchr_bin, "--daemon"]

        watch_paths Launchr::Config[:watch_paths]
        # watch_paths [Launchr::Config[:watch_paths], Launchr::Config[:launchr_root]].flatten

        # working_directory Launchr::Config[:watch_paths]
        # working_directory "/var/log/launchr"
        # working_directory Launchr::Config[:watch_paths]
        # working_directory Launchr::Path.launchr_installed_root

        user_name  Launchr.user
        group_name Launchr.group

        # also check every 15 minutes, in case brew is moved or deleted
        (0..3).each do |i|
          start_calendar_interval i do
            minute 15 * i
          end
        end

      end
    end
  end
end

