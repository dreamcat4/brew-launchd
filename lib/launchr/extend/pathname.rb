
require 'pathname'

class Pathname
  def include? partial
    self.to_s.include? partial.to_s
  end

  def chown_R user, group
    require 'fileutils'
    FileUtils.chown_R user, group, self.to_s
  end

  def user
    Etc.getpwuid(self.stat.uid).name
  end

  def group
    Etc.getgrgid(self.stat.gid).name
  end

  def touch
    require 'fileutils'
    FileUtils.touch self.to_s
  end
end

