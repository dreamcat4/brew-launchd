
require 'plist4r/mixin/mixlib_config'
require 'plist4r/backend'

Dir.glob(File.dirname(__FILE__) + "/backend/*.rb").each {|b| require File.expand_path b}

module Plist4r

  # The special configuration object, which holds all runtime defaults for individual plist instances.
  # When we create a new {Plist4r::Plist} object, it will inherit these defaults.
  # @example 
  # # Reverse the priority order of backends
  # Plist4r::Config[:backends].reverse!
  # 
  # # Set the default folder from which to load / save plist files
  # Plist4r::Config[:default_path] = "/path/to/my/plist/files"
  # 
  # # Save new plist files as binary plists (when format not known)
  # Plist4r::Config[:default_format] = :binary
  # 
  # # Add custom / application specific Plist Type. You'll also need to subclass {Plist4r::PlistType}
  # Expects class Plist4r::PlistType::MyPlistType to be defined
  # require 'my_plist_type.rb'
  # Plist4r::Config[:types] << "my_plist_type"
  # 
  # # Raise an exception plist keys which dont belong to the selected Plist type
  # Plist4r::Config[:strict_keys] = true
  class Config
    extend Mixlib::Config

    CoreFoundationFramework = "/System/Library/Frameworks/CoreFoundation.framework"
    RubycocoaFramework      = "/System/Library/Frameworks/RubyCocoa.framework"

    DefaultBackendsAny = ["c_f_property_list","haml","libxml4r"]
    DefaultBackendsOsx = ["osx_plist","c_f_property_list","haml","libxml4r"]
    
    def self.default_backends sym=nil
      case sym
      when :brew
        ["ruby_cocoa"]
      else
        if File.exists? CoreFoundationFramework
          if File.exists? RubycocoaFramework
            DefaultBackendsOsx + ["ruby_cocoa"]
          else
            DefaultBackendsOsx
          end
        else
          DefaultBackendsAny
        end
      end
    end

    types [] << Dir.glob(File.dirname(__FILE__) + "/plist_type/*.rb").collect {|b| File.basename(b,".rb") }
    types.flatten!.uniq!
    
    backends default_backends :brew
    backends << Dir.glob(File.dirname(__FILE__) + "/backend/*.rb").collect {|b| File.basename(b,".rb") }
    backends.flatten!.uniq!
    backends.delete "example"

    backend_timeout 15

    strict_keys false
    raise_any_failure false
    default_format :xml
    default_path nil
  end
end


