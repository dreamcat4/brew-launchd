
require 'plist4r/config'
require 'plist4r/mixin/ordered_hash'
require 'timeout'

module Plist4r
  # This class is the Backend broker. The purpose of this object is to manage and handle API
  # calls, passing them over to the appropriate Plist4r backends.
  # Also see the {file:Backends} Rdoc page.
  class Backend
    # The list backend API methods. A Plist4r::Backend should implement 1 or more of these methods
    # @see Plist4r::Backend::Example
    ApiMethods = %w[ from_xml from_binary from_gnustep to_xml to_binary to_gnustep ]

    # The set of Plist4r API methods which are generated by the {#generic_call} method
    # These methods don't need to be implemented by a Plist4r::Backend
    PrivateApiMethods = %w[ from_string open save ]

    # The set of Plist4r API methods with are invoked by {Plist4r::PlistCache}
    PlistCacheApiMethods = %w[from_string to_xml to_binary to_gnustep open save]

    # A new instance of Backend. A single Backend will exist for the the life of
    # the Plist object. The attribute @plist is set during initialization and 
    # refers back to the plist instance object.
    def initialize plist, *args, &blk
      @plist = plist
    end

    # Implements a generic version of each of the Plist4r Private API Calls.
    # @param [Symbol] backend the currently iterated backend from which we will try to generate the API call
    # @param [Symbol] method_sym The API method call to execute. One of {PrivateApiMethods}
    def generic_call backend, method_sym
      case method_sym

      when :save
        fmt = @plist.file_format || Plist4r::Config[:default_format]
        unless backend.respond_to? "to_#{fmt}"
          return Exception.new "Plist4r: No backend found to handle method :to_#{fmt}. Could not execute method :save on plist #{@plist.inspect}"
        end
        File.open(@plist.filename_path,'w') do |out|
          out << @plist.instance_eval { @plist_cache.send("to_#{fmt}".to_sym) }
        end

      when :open
        unless @open_fmt
          @plist.instance_eval "@from_string = File.read(filename_path)"
          @open_fmt = Plist4r.string_detect_format @plist.from_string
        end
        fmt = @open_fmt
        if backend.respond_to? "from_#{fmt}"
          @from_string_fmt = @open_fmt
          @open_fmt = nil

          @plist.instance_eval { @plist_cache.send :from_string }
        else
          return Exception.new "Plist4r: No backend found to handle method :from_#{fmt}. Could not execute method :open on plist #{@plist.inspect}"
        end

      when :from_string
        unless @from_string_fmt
          @from_string_fmt = Plist4r.string_detect_format @plist.from_string
        end
        fmt = @from_string_fmt
        if backend.respond_to? "from_#{fmt}"
          @from_string_fmt = nil

          Timeout::timeout(Plist4r::Config[:backend_timeout]) do
            backend.send("from_#{fmt}".to_sym, @plist)
          end
          @plist.file_format fmt
          @plist
        else
          return Exception.new "Plist4r: No backend found to handle method :from_#{fmt}. Could not execute method :from_string on plist #{@plist.inspect}"
        end
      end
    end

    # Call a Plist4r API Method. Here, we usually pass a {Plist4r::Plist} object
    # as one of the parameters, which will also contain all the input data to work on.
    # 
    # This function loops through the array of available backends, and calls the
    # first backend found to implement the appropriate fullfilment request.
    # 
    # If the request fails, the call is re-executed on the next available
    # backend.
    # 
    # The plist object is updated in-place and also usually placed as the return argument.
    # 
    # @raise if no backend was able to sucessfully execute the request.
    # @param [Symbol] method_sym The API method call to execute
    def call method_sym
      raise "Unsupported api call #{method_sym.inspect}" unless PlistCacheApiMethods.include? method_sym.to_s
      exceptions = []
      generic_call_exception = nil

      @plist.backends.each do |b_sym|
      backend = eval "Plist4r::Backend::#{b_sym.to_s.camelcase}"

        begin
          if backend.respond_to?(method_sym) && method_sym != :from_string
            Timeout::timeout(Plist4r::Config[:backend_timeout]) do
              return eval("#{backend}.#{method_sym} @plist")
            end

          elsif PrivateApiMethods.include? method_sym.to_s
            result = generic_call backend, method_sym
            if result.is_a? Exception
              generic_call_exception = result
            else
              return result
            end
          end

        rescue LoadError
          exceptions << $!
        rescue RuntimeError
          exceptions << $!
        rescue SyntaxError
          exceptions << $!
        rescue Exception
          exceptions << $!
        rescue Timeout::Error
          exceptions << $!
        rescue
          exceptions << $!
        end

        if Config[:raise_any_failure] && exceptions.first
          raise exceptions.first
        end
      end
      
      if exceptions.empty?
        if generic_call_exception
          raise generic_call_exception
        else
          raise "Plist4r: No backend found to handle method #{method_sym.inspect}. Could not execute method #{method_sym.inspect} on plist #{@plist.inspect}"
        end
      else
        # $stderr.puts "Failure(s) while executing method #{method_sym.inspect} on plist #{@plist}."
        exceptions.each do |e|
          $stderr.puts e.inspect
          $stderr.puts e.backtrace.collect { |l| "\tfrom #{l}"}.join "\n"
        end
        # raise exceptions.first
        raise "Failure(s) while executing method #{method_sym.inspect} on plist #{@plist}."
      end
    end
  end
end


