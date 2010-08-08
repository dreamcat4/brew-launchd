
require 'launchr/mixin/mixlib_cli'
require 'launchr/mixin/mixlib_config'

module Launchr
  # Defines options for the +launchr+ command line utility
  class CLI
    include Launchr::Mixlib::CLI

    # The Launchr CLI Options
    # 
    # @example
    # Usage: bin/launchr (options)
    #     -b, --brew        Customize for Brew. Use with --ruby-lib.
    #     -d, --dir DIR     The directory to dump files into. Use with --ruby-lib. Defaults to cwd.
    #     -r, --ruby-lib    Convert launchr gem into a ruby lib, and write to the filesystem. (required)
    #     -h, --help        Show this message
    def self.launchr_cli_options
      
      # option :dir,
      #   :short => "-d", 
      #   :long  => "--dir DIR", 
      #   :default => nil,
      #   :description => "Set the directory to watch for launchd plists"

      # test_keywords = { :yes => [:foo], :no => :foo }
      # argument :test,
      #   :long  => "[no-]test [OPT]", 
      #   # :type => Time,
      # 
      #   # :type => Float,
      #   # :type => Array,
      #   # :keywords => [:yes, :no, :maybe],
      #   # :keywords => ["yes", "no", "maybe"],
      #   # :keywords => [:maybe],
      #   # :keywords => test_keywords,
      #   # :valid_values => [1.3, 0.05, 0.2],
      #   :default => nil,
      #   :description => "Test sandbox"
      #   # :description => ["Select test, one of", "  #{test_keywords.keys.join(', ')}"]


      # argument :test,
      #   :long  => "test", 
      #   :default => nil,
      #   :description => "Test sandbox (development only)",
      #   :options => [:auto]

      spaced_summary true
      # banner false
      summary_indent ""
      summary_width 29

      header "Launchr - A command line program to control launchd services"
      # footer "\"man launchr\" for more information on launchr"
      # footer "Author: Dreamcat4 (dreamcat4@gmail.com)"

      argument :setup,
        :long  => "setup [--user|--boot]",
        # :keywords => ["--user", "--boot"],
        # :keywords => ["--user", "--boot","--auto","--no-auto"],
        # :default => :user,
        :default => nil,
        :description => [
          "Setup and authorize the launchr supervisory watch daemon",
          "at user login (default), or system boot (requires sudo).",
          "You must supply a flag to setup launchr, either --user, ",
          "or --boot (requires sudo)."
          ],
        :example => [
          "setup --user        # => ~/Library/LaunchDaemons",
          "sudo launchr setup --boot   # =>  /Library/LaunchDaemons"
          ],
        # :requires => "--boot|--user"
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") }
        
      argument :default,
        :long  => "default [--user|--boot]",
        # :keywords => ["--user", "--boot","--auto","--no-auto"],
        :default => nil,
        :description => ["Set the default target for launch services.",
          "also runs launchr setup if not already setup"],
        :example => ["default --user      # makes user login the default",
          "sudo launchr default --boot # make system boot the default"
          ],
        # :requires => "--boot|--user"
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") }

      option :auto,
        :long  => "--[no-]auto", 
        :indent => true,
        #   :description => "Automatically bring up launchd service(s) when installed"
        :description => ["Auto start launchd service(s), as soon as they are installed.",
          "Mimics the behaviour of debian and ubuntu systems",
          "This option can be set with either the setup, or default command"],
        :example => ["sudo launchr setup --boot --auto  # switch on auto start",
          "launchr default --user --no-auto  # switches off auto start"],
        :default => nil

      argument :start,
        :long  => "start service,(s)", 
        :type => Array,
        :description => ["Start launchd service(s)",
          "Equivalent to launchctl load -w files..."],
        :example => "start dnsmasq memcached couchdb",
        :default => nil

      argument :stop,
        :long  => "stop service,(s)", 
        :type => Array,
        :description => ["Stop launchd service(s)",
        "Equivalent to launchctl unload -w files..."],
        :example => "stop mamcached dnsmasq",
        :default => nil

      argument :restart,
        :long  => "restart service,(s)", 
        :type => Array,
        :description => "Restart launchd service(s)",
        :example => "restart couchdb",
        :default => nil

      argument :info,
        :long  => "info service,(s)", 
        :type => Array,
        :description => "Info for launchd service(s)",
        :example => "info couchdb",
        :default => nil

      option :user,
        :indent => true,
        :long  => "--user", 
        :description => ["Specifically start or stop launchd service(s) at user login.",
          "Useful when the default target setting is --user.",
          "Does not stop an existing system-level service by the same name."],
        :example => "start --user openvpn ddclient znc",
        :default => nil

      option :boot,
        :indent => true,
        :long  => "--boot", 
        :description => ["Specifically start or stop launchd service(s) at system boot.",
          "Useful when the default target setting is --user.",
          "Does not stop an existing user-level service by the same name."],
        :example => "launchr start --boot nginx mysql",
        :default => nil

      argument :update,
        :long  => "update [--user|--boot]", 
        :default => nil,
        :description => ["Update launchr's watch daemon from locally installed files. This",
          "executable is used to find the copy of launchr to update from."],
        :example => ["sudo launchr update --boot"],
        # :requires => "--boot|--user"
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") }

      argument :remove,
        :long  => "remove [--user|--boot]",
        :default => nil,
        :description => [
          "Remove (uninstall) the launchr supervisory watch daemon",
          "Removal also stops any running services being managed by launchr"],
        :example => ["sudo launchr remove --boot"],
        # :requires => "--boot|--user"
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") }


      # option :daemon,
      #   :long  => "--daemon", 
      #   :description => ["Daemon mode. Scans the watch folders for new plist files.",
      #     "This option is only used internally by launchr."],
      #   :default => nil
      # 
      # option :log,
      #   # :short => "-l", 
      #   :long  => "--log FILE,logger_args", 
      #   :indent => true,
      #   :type => Array,
      #   :description => ["Log actions to FILE, with optional Ruby logger args.",
      #     "See http://ruby-doc.org/core/classes/Logger.html"],
      #   :example => ["--daemon --log /var/log/launchr.log 10, 1024000",
      #     "--daemon --log /var/log/launchr.log weekly"],
      #   :default => nil
      # 
      # option :log_level,
      #   :long  => "--log-level LEVEL", 
      #   :indent => true,
      #   :keywords => [:debug, :info, :warn, :error, :fatal],
      #   :description => ["Set the log level, one of:", "debug, info, warn, error, or fatal (default: info)"],
      #   :example => "--daemon --log-level debug",
      #   :default => nil

      option :help, 
        # :short => "-h", 
        :long => "--help",
        :description => "Show this message",
        :show_options => true,
        :exit => 0
    end
    launchr_cli_options

    def parse argv=ARGV
      parse_options(argv)

      unless filtered_argv.empty?
        start_stop_restart_value = [config[:start],config[:stop],config[:restart],config[:info]].compact!
      
        if start_stop_restart_value.size == 1
          services = *start_stop_restart_value
          extra_services = filtered_argv
      
          services << extra_services
          services.flatten!

        elsif config[:log]
          logger_args = config[:log]
          extra_logger_args = filtered_argv
          logger_args << extra_logger_args
          logger_args.flatten!
        end
      end
      puts config.inspect
      # puts filtered_argv.inspect
      config
    end

  end
end
