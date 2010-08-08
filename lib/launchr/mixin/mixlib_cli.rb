
require 'optparse'
require 'optparse/date'
require 'optparse/shellwords'
require 'optparse/time'
require 'optparse/uri'

require 'launchr/mixin/ordered_hash'

module Launchr
  module Mixlib
    # <tt></tt>
    #   Author:: Adam Jacob (<adam@opscode.com>)
    #   Copyright:: Copyright (c) 2008 Opscode, Inc.
    #   License:: Apache License, Version 2.0
    #   
    #   Licensed under the Apache License, Version 2.0 (the "License");
    #   you may not use this file except in compliance with the License.
    #   You may obtain a copy of the License at
    #   
    #       http://www.apache.org/licenses/LICENSE-2.0
    #   
    #   Unless required by applicable law or agreed to in writing, software
    #   distributed under the License is distributed on an "AS IS" BASIS,
    #   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    #   See the License for the specific language governing permissions and
    #   limitations under the License.
    # 
    module CLI
      module ClassMethods       
        # Add a command line option.
        #
        # === Parameters
        # name<Symbol>:: The name of the option to add
        # args<Hash>:: A hash of arguments for the option, specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def option(name, args)
          @options ||= Launchr::OrderedHash.new
          @options_arguments ||= Launchr::OrderedHash.new
          raise(ArgumentError, "Option name must be a symbol") unless name.kind_of?(Symbol)

          strip_arg(args,:short)
          strip_arg(args,:long)
          
          @options[name.to_sym] = args
          @options_arguments[name.to_sym] = args
        end
      
        # Get the hash of current options.
        #
        # === Returns
        # @options<Hash>:: The current options hash.
        def options
          @options ||= Launchr::OrderedHash.new
          @options
        end
      
        # Set the current options hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the options to
        #
        # === Returns
        # @options<Hash>:: The current options hash.
        def options=(val)
          raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
          @options = val
        end
      
        # Add a command line argument.
        #
        # === Parameters
        # name<Symbol>:: The name of the argument to add
        # args<Hash>:: A hash of arguments for the argument, specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def argument(name, args)
          @arguments ||= Launchr::OrderedHash.new
          @options_arguments ||= Launchr::OrderedHash.new
          raise(ArgumentError, "Argument name must be a symbol") unless name.kind_of?(Symbol)

          strip_arg(args,:short)
          strip_arg(args,:long)
          convert_argument_to_option(args)

          @arguments[name.to_sym] = args.dup
          @options_arguments[name.to_sym] = args
        end

        def strip_arg args, arg
          if args[arg]
            args["#{arg}_strip".to_sym] = args[arg].sub(/\[no-\]/,"").sub(/\s*(\<|\[|=|[A-Z]|[a-zA-z]+\,|\s).*$/,"")
          end
          args
        end

        def convert_argument_to_option args
          # args = args.dup
          args[:short] = "-" + args[:short] if args[:short]
          args[:short_strip] = "-" + args[:short_strip] if args[:short_strip]
          args[:long] = "--" + args[:long]  if args[:long]
          args[:long_strip] = "--" + args[:long_strip]  if args[:long_strip]
          args
        end
      
        # Get the hash of current arguments.
        #
        # === Returns
        # @arguments<Hash>:: The current arguments hash.
        def arguments
          @arguments ||= Launchr::OrderedHash.new
          @arguments
        end
      
        # Set the current arguments hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the arguments to
        #
        # === Returns
        # @arguments<Hash>:: The current arguments hash.
        def arguments=(val)
          raise(ArgumentError, "Arguments must recieve a hash") unless val.kind_of?(Hash)
          @arguments = val
        end

        # Get the combined hash of combined current options plus current arguments.
        #
        # === Returns
        # @options_arguments<Hash>:: The combined current options and current arguments hash.
        def options_arguments
          @options_arguments ||= Launchr::OrderedHash.new
          @options_arguments
        end

        # Set the current options and current arguments combined hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the combined options and arguments to
        #
        # === Returns
        # @options_arguments<Hash>:: The current options and current arguments hash.
        def options_arguments=(val)
          raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
          @options_arguments = val
        end

        # Return the hash of current arguments as human-readable string.
        #
        # === Returns
        # <String>:: The arguments hash, one per line.
        def show_arguments
          @arguments ||= Launchr::OrderedHash.new
          summarize_arguments
        end

        # Change the banner.  Defaults to:
        #   Usage: #{0} (options)
        #
        # === Parameters
        # bstring<String>:: The string to set the banner to
        # 
        # === Returns
        # @banner<String>:: The current banner
        def banner(bstring=nil)
          case bstring
          when true
            # @banner = "usage: #{File.basename $0} [options]"
            @banner = "Usage: #{File.basename $0} [options]"
          when false
            @banner = ""
          when String
            @banner = bstring
          else
            # @banner ||= "usage: #{File.basename $0} [options]"
            @banner ||= "Usage: #{File.basename $0} [options]"
            # @banner ||= ""
            @banner
          end
        end

        # Add a line to the header.
        #
        # === Parameters
        # hstring<String>:: The next string to push onto the header
        # 
        # === Returns
        # @header<Array>:: The current header, an array of strings
        def header(hstring=nil)
          @header ||= []
          case hstring
          when Array
            @header = hstring
          when String
            @header << hstring
          when nil
            @header
          end
        end

        # Add a line to the footer.
        #
        # === Parameters
        # fstring<String>:: The next string to push onto the footer
        # 
        # === Returns
        # @footer<Array>:: The current footer, an array of strings
        def footer(fstring=nil)
          @footer ||= []
          case fstring
          when Array
            @footer = fstring
          when String
            @footer << fstring
          when nil
            @footer
          end
        end

        # Summary indent. Passed to option parser. Defaults to: ' ' * 4
        #
        # === Parameters
        # i_string<String>:: Set to the indent string
        # 
        # === Returns
        # @summary_indent<String>:: The summary indent
        def summary_indent(i_string=nil)
          if i_string
            @summary_indent = i_string
          else
            @summary_indent ||= ' ' * 4
            @summary_indent
          end
        end

        # Summary indent. Passed to option parser. Defaults to: 32
        #
        # === Parameters
        # i_string<String>:: Set to the indent string
        # 
        # === Returns
        # @summary_indent<String>:: The summary indent
        def summary_width(w_integer=nil)
          if w_integer
            @summary_width = w_integer
          else
            @summary_width ||= 32
            @summary_width
          end
        end

        # Seperate options with  empty lines.  Defaults to: false
        #
        # === Parameters
        # bool<true,false>:: Set to true for newline spacing
        # 
        # === Returns
        # @spaced_summary<String>:: The current line spacing setting
        def spaced_summary(bool=nil)
          if bool
            @spaced_summary = bool
          else
            @spaced_summary ||= false
            @spaced_summary
          end
        end

        # The remaining argv command line arguments, after parsing. Defaults to: [] (an empty array) if un-parsed
        #
        # === Returns
        # @filtered_argv<Array>:: The remaining command line arguments, after CLI options parsing.
        def filtered_argv
          @filtered_argv ||= []
          @filtered_argv
        end
      end

      attr_accessor :options, :arguments, :options_arguments, :config, :banner, :header, :footer
      attr_accessor :opt_parser, :filtered_argv, :summary_indent, :summary_width, :spaced_summary
    
      # Create a new Mixlib::CLI class.  If you override this, make sure you call super!
      #
      # === Parameters
      # *args<Array>:: The array of arguments passed to the initializer
      #
      # === Returns
      # object<Mixlib::Config>:: Returns an instance of whatever you wanted :)
      def initialize(*args)
        @options   = Launchr::OrderedHash.new
        @arguments = Launchr::OrderedHash.new
        @options_arguments = Launchr::OrderedHash.new
        @config  = Hash.new
        @filtered_argv = []
      
        # Set the banner
        @banner  = self.class.banner
        @header  = self.class.header
        @footer  = self.class.footer

        @summary_indent  = self.class.summary_indent
        @summary_width   = self.class.summary_width
        @spaced_summary  = self.class.spaced_summary
      
        # Dupe the class options for this instance
        klass_options = self.class.options
        klass_options.keys.inject(@options) { |memo, key| memo[key] = klass_options[key].dup; memo }

        # Dupe the class arguments for this instance
        klass_arguments = self.class.arguments
        klass_arguments.keys.inject(@arguments) { |memo, key| memo[key] = klass_arguments[key].dup; memo }

        # Dupe the class arguments for this instance
        klass_options_arguments = self.class.options_arguments
        klass_options_arguments.keys.inject(@options_arguments) { |memo, key| memo[key] = klass_options_arguments[key].dup; memo }
      
        # check argument and option :name keys dont conflict
        name_collision = klass_options.keys & klass_arguments.keys
        raise ArgumentError, "An option cannot have the same name as an argument: #{name_collision.join(', ')}" unless name_collision.empty?

        koso, kolo = [], []
        klass_options.each do |name, kargs|
          koso << (kargs[:short_strip] || "")
          kolo << (kargs[:long_strip] || "")
        end
        
        kasa, kala = [], []
        klass_arguments.each do |name, kargs|
          kasa << (kargs[:short_strip] || "")
          kala << (kargs[:long_strip] || "")
        end

        # Check that argument an option --long switches dont conflict
        loa_collision = kolo & kala - [""]
        opt_name = klass_options.keys[kolo.index(loa_collision.first) || 0]
        arg_name = klass_arguments.keys[kala.index(loa_collision.first) || 0]
        raise ArgumentError, "Collision: switch '#{loa_collision.first}' for option(#{opt_name.inspect}) and argument(#{arg_name.inspect}) cannot be the same" unless loa_collision.empty?

        # Check that argument an option -s short switches dont conflict
        soa_collision = koso & kasa - [""]
        opt_name = klass_options.keys[kolo.index(soa_collision.first) || 0]
        arg_name = klass_arguments.keys[kala.index(soa_collision.first) || 0]
        raise ArgumentError, "Collision: switch '#{soa_collision.first}' for option(#{opt_name.inspect}) and argument(#{arg_name.inspect}) cannot be the same" unless soa_collision.empty?
        
        # Set the default configuration values for this instance
        @options.each do |config_key, config_opts|
          config_opts[:on] ||= :on
          config_opts[:boolean] ||= false
          config_opts[:requires] ||= nil
          config_opts[:proc] ||= nil
          config_opts[:show_options] ||= false
          config_opts[:exit] ||= nil
        
          if config_opts.has_key?(:default)
            @config[config_key] = config_opts[:default]
          end
        end

        @arguments.each do |config_key, config_opts|
          config_opts[:on] ||= :on
          config_opts[:boolean] ||= false
          config_opts[:requires] ||= nil
          config_opts[:proc] ||= nil
          config_opts[:show_options] ||= false
          config_opts[:exit] ||= nil
        
          if config_opts.has_key?(:default)
            @config[config_key] = config_opts[:default]
          end
        end

        @options_arguments.each do |config_key, config_opts|
          config_opts[:on] ||= :on
          config_opts[:boolean] ||= false
          config_opts[:requires] ||= nil
          config_opts[:proc] ||= nil
          config_opts[:show_options] ||= false
          config_opts[:exit] ||= nil
        
          if config_opts.has_key?(:default)
            @config[config_key] = config_opts[:default]
          end
        end
      
        super(*args)
      end


      def guess_and_switchify_arguments argv
        # collect argument declarations
        short_args = @arguments.values.map { |args| args[:short_strip] }
        long_args  = @arguments.values.map { |args| args[:long_strip]  }

        short_opts_args = @options_arguments.values.map { |args| args[:short_strip] }
        long_opts_args  = @options_arguments.values.map { |args| args[:long_strip]  }

        short_opts_args_unfiltered = @options_arguments.values.map { |args| args[:short] }
        long_opts_args_unfiltered  = @options_arguments.values.map { |args| args[:long]  }

        i = 0
        while i < argv.size

          # switchify the argv argument if it looks like a recognised argument
          if short_args.include?("-"+argv[i].sub(/^no-/,"").sub(/(=|\s).*/,""))
            argv[i] = "-" + argv[i]
          end

          if long_args.include?("--"+argv[i].sub(/^no-/,"").sub(/(=|\s).*/,""))
            argv[i] = "--" + argv[i]
          end

          # when the argv argument matches a recognised option or argument
          # without the style =value, the following argument might have to be skipped...

          # so find the index of the switch declaration
          j = nil
          if short_opts_args.include?(argv[i])
            j = short_opts_args.index(argv[i])
          end
          if long_opts_args.include?(argv[i])
            j = long_opts_args.index(argv[i])
          end

          if j
            # when the switch declaration has a required argument
            if short_opts_args_unfiltered[j] =~ /( .+|\<|\=|[A-Z])/
              # skip forward one
              i += 1
            end
            # when the switch declaration has a required argument
            if long_opts_args_unfiltered[j] =~ /( .+|\<|\=|[A-Z])/
              # skip forward one
              i += 1
            end
          end
          # next argument
          i += 1
        end

        argv
      end
      
      # Parses an array, by default ARGV, for command line options (as configured at 
      # the class level).
      # === Parameters
      # argv<Array>:: The array of arguments to parse; defaults to ARGV
      #
      # === Returns
      # argv<Array>:: Returns any un-parsed elements.
      def parse_options(argv=ARGV)
        argv = argv.dup
        argv = guess_and_switchify_arguments(argv)
        @opt_parser = OptionParser.new do |opts|  
          # Set the banner
          opts.banner = banner        
        
          # Create new options
          options_arguments.each do |opt_key, opt_val|          
            opt_args = build_option_arguments(opt_val)
          
            opt_method = case opt_val[:on]
              when :on
                :on
              when :tail
                :on_tail
              when :head
                :on_head
              else
                raise ArgumentError, "You must pass :on, :tail, or :head to :on"
              end

            parse_block = \
              Proc.new() do |*c|
                if c.empty? || c == [nil]
                  c = true
                  config[opt_key] = (opt_val[:proc] && opt_val[:proc].call(c)) || c
                else
                  c = c.first
                  config[opt_key] = (opt_val[:proc] && opt_val[:proc].call(c)) || c
                end
                puts filter_options_summary(opts.to_s) if opt_val[:show_options]
                exit opt_val[:exit] if opt_val[:exit]
              end

            # opts.send(:on, *[opt_method,*opt_args, parse_block])
            opt_args.unshift opt_method
            opt_args << parse_block
            opts.send(*opt_args)
          end
        end

        @opt_parser.summary_indent = @summary_indent if @summary_indent
        @opt_parser.summary_width  = @summary_width  if @summary_width

        @opt_parser.parse!(argv)
        @filtered_argv = argv

        # Deal with any required values
        fail = nil
        options_arguments.each do |opt_key, opt_value|
          next unless config[opt_key]
          # next if config[opt_key] == opt_value[:default]

          reqargs = []
          case opt_value[:requires]
          when nil
          when Proc
            begin
              result = opt_value[:requires].call(config)
            rescue 
              reqargs << $!.message
            end
            reqargs << result if result.class == String
          when Array,Symbol
            required_opts = [opt_value[:requires]].flatten
            required_opts.each do |required_opt|
              reqargs << required_opt.to_sym unless config[required_opt.to_sym]
            end

            reqargs.map! do |opt|
              arg = (options_arguments[opt][:long_strip] || options_arguments[opt][:short_strip]).dup
              arg.gsub!(/^-+/,"") if arguments.keys.include?(opt)
              arg
            end
          end
          unless reqargs.empty?
            fail = true
            opt = (opt_value[:long_strip] || opt_value[:short_strip]).dup
            opt.gsub!(/^-+/,"") if arguments.keys.include?(opt_key)
            puts "You must supply #{reqargs.join(", ")} with #{opt}!"
          end

        end
        if fail
          puts filter_options_summary(@opt_parser.to_s)
          exit 2
        end

        argv
      end

      def build_option_arguments(opt_setting)      
        arguments = Array.new
        arguments << opt_setting[:short] if opt_setting.has_key?(:short)
        arguments << opt_setting[:long]  if opt_setting.has_key?(:long)

        if opt_setting.has_key?(:keywords)
          arguments << opt_setting[:keywords]

        elsif opt_setting.has_key?(:type)
          arguments << opt_setting[:type]
        end

        case opt_setting[:description]
        when Array
          lines = opt_setting[:description].dup
          # lines.first << " (required)" if opt_setting[:required]
          lines.map! do |line|
            if line == lines.first
              line
            else
              line = "  " + line if opt_setting[:indent]
              @spaced_summary ? line : "  " + line
            end
          end
          arguments += lines
        when String
          description = opt_setting[:description]
          # description = "  " + description if opt_setting[:indent]
          # description << " (required)" if opt_setting[:required]
          arguments << description
        end

        case opt_setting[:example]
        when Array
          lines = opt_setting[:example]
          example = lines.map do |line|
            if line == lines.first
              header = "Examples $ "
              header = "  " + header unless @spaced_summary
            else
              header = "         $ "
              header = "  " + header unless @spaced_summary
            end
            header = "  " + header if opt_setting[:indent]

            line_parts = line.split("#")
            if line_parts.first.include?("#{File.basename($0)} ")
              header + line
            else
              header + "#{File.basename $0} " + line
            end
          end
          arguments << " " if @spaced_summary
          arguments += example
        when /#{File.basename $0}/
          line = opt_setting[:example]
          line_parts = line.split("#")
          if line_parts.first.include?("#{File.basename($0)} ")
            line = "Example  $ " + line
            line = "  " + line if opt_setting[:indent]
          else
            line = "Example  $ #{File.basename $0} " + line
            line = "  " + line if opt_setting[:indent]
          end
          line = "  " + line unless @spaced_summary
          arguments << line
        when nil
        else
          line =  "Example  $ #{File.basename $0} " + opt_setting[:example]
          line = "  " + line if opt_setting[:indent]
          line = "  " + line unless @spaced_summary
          arguments << line
        end

        arguments
      end

      def filter_options_summary options_summary
        os = options_summary.split("\n")
        out = []

        short_args = @arguments.values.map do |args|
          args[:short] ? args[:short].sub(/([A-Z]|=|\s).*$/,"") : args[:short]
        end
        long_args = @arguments.values.map do |args|
          args[:long] ? args[:long].sub(/([A-Z]|=|\s).*$/,"") : args[:long]
        end

        os.each do |line|
          case line
          when banner
            out += [@header].flatten if @header
            unless line =~ /^\s*$/
              # line = " " + line if @spaced_summary
              out << line
            end
          else
            if @spaced_summary
              out << "" unless line =~ /^#{@opt_parser.summary_indent}\s{#{@opt_parser.summary_width},}/
            end

            line =~ /^\s+-((\[no-\])?\w+)\,?/
            short_opt = $1 || false
            line =~ /^\s+(-(\[no-\])?\w+\,?)?\s--((\[no-\])?\w+)/
            long_opt = $3 || false

            # line.sub!("-"+short_opt," "+short_opt)  if short_opt && short_args.include?("-#{short_opt}")
            # line.sub!("--"+long_opt,"  "+long_opt)  if long_opt && long_args.include?("--#{long_opt}")

            opt_value = {}
            @options_arguments.each do |key,value|
              if long_opt && value[:long_strip]
                if long_opt.sub(/^(-+)?\[no-\]/,"") == value[:long_strip].sub(/^-+/,"")
                  # puts long_opt 
                  opt_value = value
                end
              elsif short_opt && value[:short_strip]
                if short_opt.sub(/^(-+)?\[no-\]/,"") == value[:short_strip].sub(/^-+/,"")
                  # puts short_opt 
                  opt_value = value
                end
              end
            end
            line = "  " + line if opt_value[:indent]
            
            if short_opt && short_args.include?("-#{short_opt}")
              short_opt = @arguments.values[short_args.index("-#{short_opt}")][:short].sub(/^-+/,"")
              # short_opt = opt_value[:short].sub(/^-+/,"")
              line.sub!("-"+short_opt,short_opt+" ")
            end
            if long_opt && long_args.include?("--#{long_opt}")
              long_opt = @arguments.values[long_args.index("--#{long_opt}")][:long].sub(/^-+/,"")
              # long_opt = opt_value[:short].sub(/^-+/,"")
              line.sub!("--"+long_opt,long_opt+"  ")
            end

            out << line
          end
        end
        out << " " if @spaced_summary
        out += [@footer].flatten if @footer

        out
      end
    
      def self.included(receiver)
        receiver.extend(Mixlib::CLI::ClassMethods)
      end
    
    end
  end
end
