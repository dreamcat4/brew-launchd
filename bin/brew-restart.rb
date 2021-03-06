#!/usr/bin/env ruby

# Put back the command name onto ARGV
launchr_subcommand = File.basename(__FILE__).gsub(/^brew-|\.rb$/,"")
unless ["launchd"].include?(launchr_subcommand)
  ARGV.unshift launchr_subcommand
end

# Get the real path if was executed as a symlink
require 'pathname'
__FILE_REALPATH__ = Pathname.new(__FILE__).realpath
LAUNCHR_BIN = File.expand_path(File.dirname(__FILE_REALPATH__)+"/launchr")


dir = File.expand_path "../lib", File.dirname(LAUNCHR_BIN)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)


# Into the rabbit hole
require 'launchr/application'
app = Launchr::Application.new

