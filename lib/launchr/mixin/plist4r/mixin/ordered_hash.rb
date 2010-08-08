
module Plist4r
  module ActiveSupport
    # ActiveSupport::OrderedHash
    # 
    # Copyright (c) 2005 David Hansson, 
    #
    # Copyright (c) 2007 Mauricio Fernandez, Sam Stephenson
    #
    # Copyright (c) 2008 Steve Purcell, Josh Peek
    #
    # Copyright (c) 2009 Christoffer Sawicki
    #
    # Permission is hereby granted, free of charge, to any person obtaining
    # a copy of this software and associated documentation files (the
    # "Software"), to deal in the Software without restriction, including
    # without limitation the rights to use, copy, modify, merge, publish,
    # distribute, sublicense, and/or sell copies of the Software, and to
    # permit persons to whom the Software is furnished to do so, subject to
    # the following conditions:
    #
    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #
    class OrderedHash < Hash
      def initialize(*args, &block)
        super
        @keys = []
      end

      def self.[](*args)
        ordered_hash = new

        if (args.length == 1 && args.first.is_a?(Array))
          args.first.each do |key_value_pair|
            next unless (key_value_pair.is_a?(Array))
            ordered_hash[key_value_pair[0]] = key_value_pair[1]
          end

          return ordered_hash
        end

        unless (args.size % 2 == 0)
          raise ArgumentError.new("odd number of arguments for Hash")
        end

        args.each_with_index do |val, ind|
          next if (ind % 2 != 0)
          ordered_hash[val] = args[ind + 1]
        end

        ordered_hash
      end

      def initialize_copy(other)
        super
        # make a deep copy of keys
        @keys = other.keys
      end

      def store(key, value)
        @keys << key if !has_key?(key)
        super
      end

      def []=(key, value)
        @keys << key if !has_key?(key)
        super
      end

      def delete(key)
        if has_key? key
          index = @keys.index(key)
          @keys.delete_at index
        end
        super
      end

      def delete_if
        super
        sync_keys!
        self
      end

      def reject!
        super
        sync_keys!
        self
      end

      def reject(&block)
        dup.reject!(&block)
      end

      def keys
        (@keys || []).dup
      end

      def values
        @keys.collect { |key| self[key] }
      end

      def to_hash
        self
      end

      def to_a
        @keys.map { |key| [ key, self[key] ] }
      end

      def each_key
        @keys.each { |key| yield key }
      end

      def each_value
        @keys.each { |key| yield self[key]}
      end

      def each
        @keys.each {|key| yield [key, self[key]]}
      end

      alias_method :each_pair, :each

      def clear
        super
        @keys.clear
        self
      end

      def shift
        k = @keys.first
        v = delete(k)
        [k, v]
      end

      def merge!(other_hash)
        other_hash.each {|k,v| self[k] = v }
        self
      end

      def merge(other_hash)
        dup.merge!(other_hash)
      end

      # When replacing with another hash, the initial order of our keys must come from the other hash -ordered or not.
      def replace(other)
        super
        @keys = other.keys
        self
      end

      def inspect
        "#<OrderedHash #{super}>"
      end

    private

      def sync_keys!
        @keys.delete_if {|k| !has_key?(k)}
      end
    end
  end
end

module Plist4r
  if RUBY_VERSION >= '1.9'
    # Inheritance
    #   Ruby 1.9 < Hash
    #   Ruby 1.8 < ActiveSupport::OrderedHash
    class OrderedHash < ::Hash
    end
  else
    # Inheritance
    #   Ruby 1.9 < Hash
    #   Ruby 1.8 < ActiveSupport::OrderedHash
    class OrderedHash < Plist4r::ActiveSupport::OrderedHash
    end
  end
end



