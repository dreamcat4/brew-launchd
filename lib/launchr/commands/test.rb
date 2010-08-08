
require 'launchr/path'

module Launchr
  class Commands

    # Test sandbox.
    # @see Launchr::CLI
    def test value
      puts "value = #{value.inspect}"

      # puts Launchr::Path.launchr_bin
      # puts Launchr::Path.launchr_bin_realname
      puts Launchr::Path.launchr_root
      puts Launchr::Path.launchr_version
      puts Launchr::Path.commandline?
      puts Launchr::Path.cwd_launchr_root
      puts Launchr.user
      puts Launchr.group
      puts ""

      puts Launchr::Path.application_support
      puts Launchr::Path.launch_daemons
      puts Launchr::Path.launchr_config
      puts ""
      
      # puts ENV.inspect
      # puts Launchr::Config.configuration.each do |k,v|
      # puts Launchr::Config.configuration.inspect

      puts Launchr::Config.configuration.inspect
      puts ""

      # print Launchr::Config.to_s.inspect
      # Launchr::Config[:label] = "point a"
      # s = Launchr::Config.to_s

      # Launchr::Config[:label] = "point b"
      # puts Launchr::Config.from_string(s).inspect
      
      
      
    end
  end
end

