
require 'launchr'

require 'fileutils'
require 'pathname'

module Launchr
  module Path
    class << self
      def launch_daemons
        if Launchr.superuser?
          File.expand_path("/Library/LaunchDaemons")
        else
          File.expand_path("~/Library/LaunchAgents")
        end
      end

      def user_launchdaemons
        File.expand_path("~/Library/LaunchAgents")
      end

      def boot_launchdaemons
        File.expand_path("/Library/LaunchDaemons")
      end

      def brew_launchdaemons
        if homebrew_prefix
          "#{Launchr::Path.homebrew_prefix}/Library/LaunchDaemons"
        else
          false
        end
      end

      def launchr_config
        File.expand_path("~/Library/Preferences/#{Launchr.label}.prefs")
      end

      def launchr_bin
        LAUNCHR_BIN
      end

      def launchr_root
        File.expand_path "../", File.dirname(launchr_bin)
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

      # Same as Kernel.const_defined?, except it works for global constants
      def global_const_defined? string
        begin
          eval string
          true
        rescue NameError
          false
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

      def chown_down path
        if Launchr.superuser?
          FileUtils.chown_R Launchr.user, Launchr.group, path
        end
      end

    end
  end
end













