
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

      header "brew launchd - an extension to start and stop Launchd services."
      header "              `man brew-launchd` for more information"
      header ""
      banner "Usage: brew launchd [options]"

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
        :example => "start --user openvpn ddclient",
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") },
        :default => nil

      option :boot,
        :indent => true,
        :long  => "--boot", 
        :description => ["At boot time. Requires sudo/root privelidges.",
          "Otherwise, the default setting will be used."],
        :example => "sudo brew start --boot nginx mysql",
        :requires => Proc.new { |args| (args[:boot] ^ args[:user]) && true || raise("--boot|--user") },
        :default => nil


      argument :info,
        :long  => "info [service,(s)]", 
        :type => Array,
        :proc => Proc.new { |l| (l == true) ? [] : l },
        :description => ["Info for launchd service(s)","With no arguments prints info for all services."],
        :example => "brew launchd info",
        :default => nil

      argument :clean,
        :long  => "clean", 
        :description => ["Clean missing/broken launchd service(s)."],
        :example => ["brew launchd clean", "sudo brew launchd clean"],
        :default => nil

      argument :default,
        :long  => "default [--user|--boot]",
        :description => [
          "Set the default target to start launchd services.",
          "The initial setting, --user will start daemons at",
          "user login - from the Loginwindow (not over ssh).",
          " ",
          "Wheras --boot will set services to start at boot",
          "time. But be aware that brew should be installed",
          "to the root filesystem, not on a mounted volume."],

        :example => [
          "brew launchd default --boot",
          "brew launchd default --user"
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

      [:start,:stop,:restart].each do |cmd|
        case config[cmd]
        when Array
          [:user, :boot].each do |level|
            if config[cmd].include? "--#{level}"
              config[level] = true
            end
          end
          config[cmd] -= ["--user","--boot"]
        end
      end

      raise "Please choose one of --user|--boot" if config[:user] && config[:boot]

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
