
# These methods should all be nemespaced to ::Plist4r
# we don't want to upset anyone else's code

class Object
  # The method name
  # @return [String] The name of the current method
  # @example
  #  def my_method
  #    method_name
  #  end
  # my_method => "my_method"
  def method_name
    if  /`(.*)'/.match(caller.first)
      return $1
    end
    nil
  end

  # Make a deep copy of an object. Including a deep copy of all the object's instance data.
  # @example
  #  copy_of_obj = obj.deep_clone
  # @return [Object] A new copy of the object
  def deep_clone; Marshal::load(Marshal.dump(self)); end
end

class Array
  # And array is considered multi-dimensional if all of the first-order elements are also arrays.
  # @example
  #  [[1],[2],[3]].multidim?
  #  => true
  #  
  #  [[1],2,[3]].multidim?
  #  => false
  # @return [true,false] true for a Multi-Dimensional array, false otherwise
  def multidim?
    case self.size
    when 0
      false
    else
      each do |e|
        return false unless e.class == Array
      end
      true
    end
  end

  # Converts an array of values (which must respond to #succ) to an array of ranges. For example,
  # @example
  #  [3,4,5,1,6,9,8].to_ranges => [1,3..6,8..9] 
  def to_ranges
    array = self.compact.uniq.sort
    ranges = []
    if !array.empty?
      # Initialize the left and right endpoints of the range
      left, right = array.first, nil
      array.each do |obj|
        # If the right endpoint is set and obj is not equal to right's successor 
        # then we need to create a range.
        if right && obj != right.succ
          ranges << Range.new(left,right)
          left = obj
        end
        right = obj
      end
      ranges << Range.new(left,right)
    end
    ranges
  end
end

class Hash
  # Merge together an array of complex hash structures
  # @example
  #   @aohoa1 = {}
  #   
  #   @aohoa2 = [
  #     { :array1 => [:a], :array2 => [:a,:b], :array3 => [:a,:b,:c] },
  #     { :array1 => [:aa], :array2 => [:aa,:bb], :array3 => [:aa,:bb,:cc] },
  #     { :array1 => [:aaa], :array2 => [:aaa,:bbb], :array3 => [:aaa,:bbb,:ccc] }
  #   ]
  #   
  #   @aohoa1.merge_array_of_hashes_of_arrays(@aohoa2)
  #   => { 
  #     :array1 => [:a,:aa,:aaa], 
  #     :array2 => [:a,:b,:aa,:bb,:aaa,:bbb], 
  #     :array3 => [:a,:b,:c,:aa,:bb,:cc,:aaa,:bbb,:ccc]
  #   }
  # @see Plist4r::PlistType::Info::ValidKeys
  def merge_array_of_hashes_of_arrays array_of_hashes_of_arrays
    a = array_of_hashes_of_arrays
    raise "not an array_of_hashes_of_arrays" unless a.is_a? Array
    if a[0].is_a? Hash
      h = self.deep_clone
      a.each_index do |i|
        raise "not an array_of_hashes_of_arrays" unless a[i].is_a? Hash
        a[i].each do |k,v|
          raise "not an array_of_hashes_of_arrays" unless v.is_a? Array
          h[k] = [h[k]].flatten.compact + v
        end
      end
    else
      raise "not an array_of_hashes_of_arrays"
    end
    h
  end

  # @see #merge_array_of_hashes_of_arrays
  def merge_array_of_hashes_of_arrays! array_of_hashes_of_arrays
    h = merge_array_of_hashes_of_arrays array_of_hashes_of_arrays
    self.replace h
    self
  end
end

class Range
  # The Range's computed size, ie the number of elements in range.
  # @example
  #  (3..3).size
  #  => 1
  #  
  #  (0..9).size
  #  => 10
  # @return The size of the range
  def size
    last - first + 1
  end

  # The intersection of 2 ranges. Returns nil if there are no common elements.
  # @example
  #  1..10 & 5..15 => 5..10
  # @return [Range, nil] The intesection between 2 overlapping ranges, or zero
  def & other_range
    case other_range
    when Range
      intersection = []
      each do |i|
        intersection << i if other_range.include? i
      end
      result = intersection.to_ranges
      case result[0]
      when Integer
        return (result[0])..(result[0])
      when Range, nil
        return result[0]
      end
    else
      raise "unsupported type"
    end
  end

  # Does this range wholely include other_range? (true or false)
  # @example
  #  (3..5).include_range? (3..3)
  #  => true
  # 
  #  (0..4).include_range? (6..7)
  #  => false
  # @return [true, false]
  def include_range? other_range
    case other_range
    when Range
      if other_range.first >= self.first && other_range.last <= self.last
        return true
      else
        return false
      end
    else
      raise "unsupported type"
    end
  end
end

class String
  # The blob status of this string (set this to true if a binary string)
  attr_accessor :blob

  # Returns whether or not +str+ is a blob.
  # @return [true,false] If true, this string contains binary data. If false, its a regular string
  def blob?
    @blob
  end

  # A Camel-ized string. The reverse of {#snake_case}
  # @example
  #  "my_plist_key".camelcase => "MyPlistKey"
  def camelcase
    str = self.dup.gsub(/(^|[-_.\s])([a-zA-Z0-9])/) { $2.upcase } \
                  .gsub('+', 'x')
  end

  # A snake-cased string. The reverse of {#camelcase}
  # @example
  #  "MyPlistKey".snake_case => "my_plist_key"
  def snake_case
    str = self.dup.gsub(/[A-Z]/) {|s| "_" + s}
    str = str.downcase.sub(/^\_/, "")
  end
end

class Float
    alias_method :round_orig, :round
    # Round to nearest n decimal places
    # @example
    #  16.347.round(2) => 16.35
    def round(n=0)
      sprintf("%#{n}.#{n}f", self).to_f
    end
end





