
require 'plist4r/backend'
require 'plist4r/mixin/ruby_stdlib'

module Plist4r
  class PlistCache
    def initialize plist, *args, &blk
      @checksum = {}
      @plist = plist
      @backend = Backend.new plist, *args, &blk
    end
  
    def from_string
      if @from_string == @plist.from_string
        unless @from_string_plist_type == @plist.plist_type
          @from_string_plist_type = @plist.detect_plist_type
        end
        unless @from_string_file_format == @plist.file_format
          @plist.file_format @from_string_file_format
        end
      else
        @backend.call :from_string
        @from_string = @plist.from_string
        @from_string_file_format = @plist.file_format

        @plist.detect_plist_type
        unless @from_string_plist_type == @plist.plist_type
          @from_string_plist_type = @plist.plist_type
        end
      end
      @plist
    end

    def update_checksum_for fmt
      @checksum[fmt] = @plist.to_hash.hash
    end

    def needs_update_for fmt
      @checksum[fmt] != @plist.to_hash.hash
    end

    def to_xml
      if needs_update_for(:xml) || @xml.nil?
        @xml = @backend.call :to_xml
        update_checksum_for(:xml)
      end
      @xml
    end

    def to_binary
      if needs_update_for(:binary) || @binary.nil?
        @binary = @backend.call :to_binary
        update_checksum_for(:binary)
      end
      @binary
    end

    def to_gnustep
      if needs_update_for(:gnustep) || @gnustep.nil?
        @gnustep = @backend.call :to_gnustep
        update_checksum_for(:gnustep)
      end
      @gnustep
    end

    def open
      @backend.call :open
      @plist
    end

    def save
      @backend.call :save
      @plist.filename_path
    end
  end
end
