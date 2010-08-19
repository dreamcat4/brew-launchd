#!/usr/bin/env ruby

require 'mkmf'
create_makefile("launchd-socket-listener-unload")

makefile = File.read("Makefile")
makefile.gsub!(/-bundle ?/,"")
makefile.gsub!(/\$\(TARGET\)\.bundle/,"$(TARGET)")

File.open("Makefile","w") do |f|
  f.puts makefile
end


