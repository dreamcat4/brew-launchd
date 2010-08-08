
require 'launchr/mixin/mixlib_cli'

module Launchr
  # Defines options for the +launchr+ command line utility
  class CLI
    include Launchr::Mixlib::CLI

    # The Launchr CLI Options
    def self.launchr_cli_options

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
        :description => ["Restart launchd service(s)"],
        :example => "restart couchdb",
        :default => nil

      option :user,
        :indent => true,
        :long  => "--user", 
        :description => ["At user login.",
          "Otherwise, the default setting will be used."],
        :example => "start --user openvpn ddclient znc",
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") },
        :default => nil

      option :boot,
        :indent => true,
        :long  => "--boot", 
        :description => ["At boot time. Requires sudo / root privelidges.",
          "Otherwise, the default setting will be used."],
        :example => "sudo launchr start --boot nginx mysql",
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") },
        :default => nil


      argument :info,
        :long  => "info [service,(s)]", 
        :type => Array,
        :proc => Proc.new { |l| (l == true) ? [] : l },
        :description => ["Info for launchd service(s)","Or with no arguments, print info for all installed services."],
        :example => "info",
        :default => nil

      argument :clean,
        :long  => "clean", 
        :description => ["Clean missing/broken launchd service(s)."],
        :example => ["clean", "sudo launchr clean"],
        :default => nil

      argument :default,
        :long  => "default [--user|--boot]",
        :description => ["Set the default target for launchd services. Defaults to --user,",
          "which will start daemons at user login (ie via Loginwindow, not ssh).",
          " ","Whearas --boot will ensure all services are set to start at boot time.",
          "This option can be overriden on a case-by-case basis."],
        :example => [
          "sudo launchr default --boot # make system boot the default choice",
          "default --user      # return to user login as the default"
          ],
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") },
        :default => nil

      option :help, 
        :long => "--help",
        :description => "Show this message",
        :show_options => true,
        :exit => 0

      option :version, 
        :long => "--version",
        :description => "Print version information",
        :default => nil
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

      config
    end

  end
end
