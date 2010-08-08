
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'plist4r/plist'

# Almost everything required by Plist4r is fully encapsulated within the {Plist4r} namespace.
# However there are a few exceptions. We had to add a couple methods to {Object} and {String}.
module Plist4r
  class << self
    
    # Calls Plist4r::Plist.new with the supplied arguments and block
    # 
    # @return [Plist4r::Plist] The new Plist object
    # @see Plist4r::Plist#initialize
    # @example Create new, empty plist
    # Plist4r.new => #<Plist4r::Plist:0x111546c @file_format=nil, ...>
    # @api public
    def new *args, &blk
      return Plist.new *args, &blk
    end

    # Opens a plist file
    # 
    # @param [String] filename plist file to load
    # @return [Plist4r::Plist] The loaded Plist object
    # @example Load from file
    # Plist4r.open("example.plist") => #<Plist4r::Plist:0x1152d1c @file_format="xml", ...>
    # @see Plist4r::Plist#initialize
    # @see Plist4r::Plist#open
    # @api public
    def open filename, *args, &blk
      p = Plist.new filename, *args, &blk
      p.open
    end

    # Given an string of Plist data, peek the first few bytes and detect the file format
    # 
    # @param [String] string of plist data
    # @return [Symbol] A Symbol representing the plist data type. One of: Plist4r::Plist.FileFormats
    # @see Plist4r::Plist.FileFormats
    # @example
    # Plist4r.string_detect_format("{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }") => :gnustep
    def string_detect_format string
      if RUBY_VERSION >= '1.9'
        string = string.force_encoding(Encoding::ASCII_8BIT)
      end


      string.strip! if string[0,1] =~ /\s/
      case string[0,1]
      when "{","("
        :gnustep
      when "b"
        if string =~ /^bplist/
          :binary
        else
          nil
        end
      when "<"
        if string =~ /^\<\?xml/ && string =~ /\<\!DOCTYPE plist/
          :xml
        else
          nil
        end
      else
        nil
      end
    end

    # Given a Plist filename, peek the first few bytes and detect the file format
    # 
    # @param [String] filename plist file to check
    # @return [Symbol] A Symbol representing the plist data type. One of: Plist4r::Plist.FileFormats
    # @see Plist4r.string_detect_format
    # @see Plist4r::Plist.FileFormats
    def file_detect_format filename
      string_detect_format File.read(filename)
    end
  end
end

class String

  # Converts a string of plist data into a new Plist4r::Plist object
  # 
  # @return [Plist4r::Plist] The new Plist object
  # @see Plist4r::Plist#initialize
  # @api public
  def to_plist
    return ::Plist4r.new(:from_string => self)
  end
end



