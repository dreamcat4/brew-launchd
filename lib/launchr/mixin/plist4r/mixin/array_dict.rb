
require 'plist4r/mixin/data_methods'

module Plist4r
  # Abstract Base class. Represents some nested data structure within an open {Plist4r::Plist}.
  # Typically, a {Plist4r::PlistType} will create and build upon nested instances of this class.
  class ArrayDict
    include Plist4r::DataMethods

    # The initializer for this object. Here we set a reference to our raw data structure,
    # which typically is a nested hash within the plist root hash object.
    # Or an Array type structure if index is set.
    # @param [OrderedHash] orig The nested hash object which this structure represents.
    # @param [Fixnum] index The Array index (if representing an Array structure)
    def initialize orig, index=nil, &blk
      @orig = orig
      @orig = @orig[index] if index
      @hash = ::Plist4r::OrderedHash.new

      @block = blk
      instance_eval(&@block) if block_given?
    end

    # The raw data object
    # @return [Plist4r::OrderedHash] @hash
    def hash
      @hash
    end

    # Select (keep) plist keys from the object.
    # Copy them to the resultant object moving forward.
    # @param [Array, *args] keys The list of Plist Keys to keep
    def select *keys
      keys.flatten.each do |k|
        k = k.to_s.camelcase if k.class == Symbol
        @hash[k] = @orig[k] if @orig[k]
      end
    end

    # Unselect (delete) plist keys from the object.
    # @param [Array, *args] keys The list of Plist Keys to delete
    def unselect *keys
      @hash = @orig
      keys.flatten.each do |k|
        k = k.to_s.camelcase if k.class == Symbol
        @hash.delete k
      end
    end

    # Unselect (delete) all plist keys from the object.
    def unselect_all
      @hash = Plist4r::OrderedHash.new
    end

    # Select (keep) all plist keys from the object.
    # Copy them to the resultant object moving forward.
    def select_all
      @hash = @orig
    end
  end
end
