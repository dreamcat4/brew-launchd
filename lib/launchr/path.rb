
require 'launchr'
require 'pathname'

module Launchr
  module Path
    class << self
      def user_launchdaemons
        Pathname.new("~/Library/LaunchAgents").expand_path
      end

      def boot_launchdaemons
        Pathname.new("/Library/LaunchDaemons")
      end

      def brew_launchdaemons
        if homebrew_prefix
          homebrew_prefix+"Library/LaunchDaemons"
        else
          false
        end
      end

      def launchr_default_boot
        Pathname.new("~/Library/Preferences/#{Launchr.label}.default-boot").expand_path
      end

      def launchr_bin
        Pathname.new(LAUNCHR_BIN).expand_path
      end

      def launchr_root
        launchr_bin.dirname.parent
      end

      def launchr_version
        launchr_root+"VERSION"
      end

      def cwd_homebrew_prefix
        case @cwd_homebrew_prefix
        when nil
          Pathname.pwd.ascend do |path|
            if (path+"/Library/Homebrew").exist?
              @cwd_homebrew_prefix = path
              break
            end
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
          elsif launchr_root.include?("Cellar/launchr")
            @bin_homebrew_prefix = Pathname.new(launchr_root.to_s.gsub(/\/Cellar\/launchr.*$/,""))
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
          FileUtils.chown_R Launchr.user, Launchr.group, path.to_s
        end
      end

    end
  end
end













