
require 'launchr/mixin/mixlib_log'

module Launchr
  class Log
    extend Mixlib::Log
  end
end

Launchr::Log.level = :info

