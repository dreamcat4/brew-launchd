
require 'launchr/mixin/mixlib_config'
require 'launchr/mixin/plist4r'

module Launchr

  # The special configuration object, which holds all runtime defaults for individual plist instances.
  # When we create a new {Launchr::Plist} object, it will inherit these defaults.
  # @example 
  class Config
    extend Mixlib::Config

    label Launchr.label
    watch_paths []
    watch_path_labels []

    class << self
      def init
        @filename = Launchr::Path.launchr_config
      end

      # Set or return the filename attribute of the plist object. Used in cojunction with the {#path} attribute
      # @param [String] filename either a relative path or absolute
      # @return The plist's filename
      # @see Plist::Plist#open
      # @see Plist::Plist#save
      # @see Plist::Plist#save_as
      def filename filename=nil
        case filename
        when String
          @filename = filename
        when nil
          @filename
        else
          raise "Please specify a filename"
        end
      end

      # Set or return the path attribute of the plist object. Pre-pended to the plist's filename (if filename is path-relative)
      # @param [String] path (must be an absolute pathname)
      # @return The plist's working path
      # @see Plist::Plist#filename_path
      def path path=nil
        case path
        when String
          @path = path
        when nil
          @path
        else
          raise "Please specify a directory"
        end
      end

      # Set or return the combined filename+path.
      # We use this method in the backends api as the full path to load / save
      # @param [String] filename_path concactenation of both filename and path elements. Also sets the @filename and @path attributes
      # @return the full, expanded path to the plist file
      # @see filename
      # @see path
      def filename_path filename_path=nil
        case filename_path
        when String
          @filename = File.basename filename_path
          @path     = File.dirname  filename_path
        when nil
          # puts @filename.inspect
          # puts @path.inspect
          File.expand_path @filename, @path    
        else
          raise "Please specify directory + filename"
        end
      end

      def load_or_create
        if File.exists?(filename_path)
          load
        else
          FileUtils.mkdir_p File.dirname(filename_path)
          save
        end
      end
      
      def load filename=nil
        @filename = filename if filename
        raise "No filename specified" unless @filename
        from_file(filename_path)
      end

      def import_args
        sticky_args = [:lock_sudo, :auto_start, :manual]
        other_args = [:user, :boot]

        sticky_args.each do |sticky_arg|
          unless Launchr::Config[:args][sticky_arg].nil?
            Launchr::Config[sticky_arg] = Launchr::Config[:args][sticky_arg]
          end
        end
        
        other_args.each do |arg|
          Launchr::Config[arg] = Launchr::Config[:args][arg]
        end
      end

      def save
        raise "No filename specified" unless @filename
        Launchr::Config.configuration.delete(:args)
        to_file(filename_path)
        Launchr::Path.chown_down(filename_path)
      end

      def save_as filename
        @filename = filename
        save
      end

      
    end


  end
end


