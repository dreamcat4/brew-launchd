
require 'launchr'
require 'launchr/mixin/ruby_stdlib'

require 'fileutils'
require 'pathname'

module Launchr
  module Path
    class << self
      def launch_daemons
        if Launchr.superuser?
          File.expand_path("/Library/LaunchDaemons")
        else
          File.expand_path("~/Library/LaunchDaemons")
        end
      end
      
      def brew_launchdaemons
        if homebrew_prefix
          "#{Launchr::Path.homebrew_prefix}/Library/LaunchDaemons"
        else
          false
        end
      end

      def application_support
        if Launchr.superuser?
          File.expand_path("/Library/Application Support")
        else
          File.expand_path("~/Library/Application Support")
        end
      end

      def launchr_config
        File.expand_path("~/Library/Preferences/#{Launchr.label}.prefs")
      end

      def launchr_bin
        LAUNCHR_BIN
      end

      def launchr_bin_realname
        File.basename(launchr_bin)
      end

      def launchr_root
        File.expand_path "../", File.dirname(launchr_bin)
      end

      def launchr_installed_root
        File.expand_path(application_support+"/launchr")
      end

      def launchr_installed_bin
        File.expand_path(launchr_installed_root+"/bin/launchr")
      end

      def launchr_version
        File.expand_path(launchr_root+"/VERSION")
      end

      def launchr_installed_version
        File.expand_path(launchr_installed_root+"/VERSION")
      end

      def commandline?
        launchr_root != launchr_installed_root
      end

      def cwd_launchr_root
        case @cwd_launchr_root
        when nil
          cwd = FileUtils.pwd
          path = cwd

          while path != "/"
            if File.exists?(path+"/bin/"+launchr_bin_realname)
              @cwd_launchr_root = path
              break
            end
            path = File.dirname(path)
          end
          @cwd_launchr_root ||= false
        else
          @cwd_launchr_root
        end
      end
      
      def cwd_homebrew_prefix
        case @cwd_homebrew_prefix
        when nil
          cwd = FileUtils.pwd
          path = cwd

          while path != "/"
            if File.exists?(path+"/Library/Homebrew")
              @cwd_homebrew_prefix = path
              break
            end
            path = File.dirname(path)
          end
          @cwd_homebrew_prefix ||= false
        else
          @cwd_homebrew_prefix
        end
      end

      def bin_homebrew_prefix
        case @bin_homebrew_prefix
        when nil
          if global_const_defined?("HOMEBREW_PREFIX")
            @bin_homebrew_prefix = HOMEBREW_PREFIX
            # puts HOMEBREW_PREFIX.inspect
          elsif launchr_root.include?("Cellar/launchr")
            @bin_homebrew_prefix = launchr_root.gsub(/\/Cellar\/launchr.*$/,"")
          end

          @bin_homebrew_prefix ||= false
        else
          @bin_homebrew_prefix
        end
      end

      def homebrew_prefix
        # cwd_homebrew_prefix || bin_homebrew_prefix
        bin_homebrew_prefix
      end

      def watch_path
        case @watch_path
        when nil
          if homebrew_prefix
            @watch_path ||= File.expand_path(homebrew_prefix+"/Library/LaunchDaemons")
          end
          @watch_path ||= false
        else
          @watch_path
        end
      end

      def chown_down path
        if Launchr.superuser?
          FileUtils.chown_R Launchr.user, Launchr.group, path
        end
      end
      
      def launchr_spool
        "/var/spool/launchr"
        "/var/spool/launchr/starting"
        "/var/spool/launchr/stopping"
        "/var/spool/launchr/restarting"
      end

      def launchd_db
        "/private/var/db/launchd.db"
      end

      def launchr_db_root
        # "/private/var/db/launchd.db/com.github.launchr/"
        # "#{launchd_db}/com.apple.launchd/#{Launchr.label}"
        "#{launchd_db}/#{Launchr.label}"
      end

      def launchr_db_user
        # "/private/var/db/launchd.db/com.github.launchr.peruser.502/"
        # "#{launchd_db}/com.apple.launchd.peruser.#{Launchr.uid}/#{Launchr.label}"
        "#{launchd_db}/#{Launchr.label}.peruser.#{Launchr.uid}"
      end

    end
  end
end













