
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# require 'launchr/path'

module Launchr
  class << self
    def label
      # "com.github.homebrew.launchr"
      "com.github.launchr"
    end

    def real_user
      Etc.getpwuid(Process.uid).name
    end

    def real_group
      Etc.getgrgid(Process.gid).name
    end

    def superuser?
      real_user == "root"
    end

    def sudo_user
      if ENV["SUDO_USER"]
        ENV["SUDO_USER"]
      elsif ENV["SUDO_UID"]
        Etc.getpwuid(ENV["SUDO_UID"].to_i).name
      else
        nil
      end
    end

    def sudo_group
      if ENV["SUDO_GROUP"]
        ENV["SUDO_GROUP"]
      elsif ENV["SUDO_GID"]
        Etc.getgrgid(ENV["SUDO_GID"].to_i).name
      else
        nil
      end
    end

    def user
      if superuser?
        sudo_user || real_user
      else
        real_user
      end
    end

    def group
      if superuser?
        sudo_group || real_group
      else
        real_group
      end
    end

    def uid
      Etc.getpwnam(user).uid
    end

    def gid
      Etc.getgrnam(group).gid
    end
  end
end


