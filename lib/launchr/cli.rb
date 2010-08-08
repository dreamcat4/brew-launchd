
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

      argument :info, # could be "status"
        :long  => "info [service,(s)]", 
        :type => Array,
        :proc => Proc.new { |l| (l == true) ? [] : l },
        :description => "Info for launchd service(s)",
        :example => "info couchdb",
        :default => nil

      argument :clean,
        :long  => "clean", 
        :description => "Clean missing/broken launchd service(s)",
        :example => ["clean", "sudo launchr clean"],
        :default => nil

      option :user,
        :indent => true,
        :long  => "--user", 
        :description => ["Specifically start or stop launchd service(s) at user login.",
          "Otherwise, the sudo status will be used.","This option isnt strictly necessary."],
        :example => "start --user openvpn ddclient znc",
        :default => nil

      option :boot,
        :indent => true,
        :long  => "--boot", 
        :description => ["Specifically start or stop launchd service(s) at system boot.",
          "Otherwise, the process UID will be used. Requires sudo / root privelidges","This option isnt strictly necessary."],
        :example => "sudo launchr start --boot nginx mysql",
        :default => nil

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
        end
      end

      puts config.inspect
      # puts filtered_argv.inspect
      config
    end

  end
end
