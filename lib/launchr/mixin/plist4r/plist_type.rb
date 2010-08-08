
require 'plist4r/mixin/data_methods'
require 'plist4r/mixin/array_dict'

module Plist4r
  class PlistType
    include ::Plist4r::DataMethods

    ValidKeys = {}

    # @param [Plist4r::Plist] plist A pointer referencing back to the plist object
    def initialize plist, *args, &blk
      @plist = plist
      @hash = @orig = plist.to_hash
    end
    
    # Set or return the plist's raw data object
    # @param [Plist4r::OrderedHash] hash Set the hash if not nil
    # @return [Plist4r::OrderedHash] @hash
    def hash hash=nil
      case hash
      when ::Plist4r::OrderedHash
        @hash = @orig = hash
      when nil
        @hash
      else
        raise "Must hash be an ::Plist4r::OrderedHash"
      end
    end

    # Compare a list of foreign keys to the valid keys for this known PlistType.
    # Generate statistics about how many keys (what proportion) match the the key names
    # match this particular PlistType.
    # @param [Array] plist_keys The list of keys to compare to this PlistType
    # @return [Hash] A hash of the match statistics
    # @see Plist4r::Plist#detect_plist_type
    # @example
    #  Plist4r::PlistType::Launchd.match_stat ["ProgramArguments","Sockets","SomeArbitraryKeyName"]
    #  # => { :matches => 2, :ratio => 0.0465116279069767 }
    def self.match_stat plist_keys
      type_keys = self::ValidKeys.values.flatten
      matches = plist_keys & type_keys
      include_ratio = matches.size.to_f / type_keys.size
      return :matches => matches.size, :ratio => include_ratio
    end

    # @return The shortform string, in snake case, a unique name
    # @example
    #  pt = Plist4r::PlistType::Launchd.new
    #  pt.to_s
    #  # => "launchd"
    def to_s
      return @string ||= self.class.to_s.gsub(/.*:/,"").snake_case
    end

    # @return A symbol representation the shortform string, in snake case, a unique name
    # @example
    #  pt = Plist4r::PlistType::Launchd.new
    #  pt.to_sym
    #  # => :launchd
    def to_sym
      return @sym ||= to_s.to_sym
    end

    def array_dict method_sym, *args
      a = ArrayDict.new @hash
      result = eval "a.#{method_sym} *args"
      @hash = @orig = a.hash
      @plist.import_hash a.hash
    end
  end
end
