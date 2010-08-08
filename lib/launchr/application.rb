
require 'launchr/path'
require 'launchr/config'

require 'launchr/cli'
require 'launchr/commands'

module Launchr
  # The Launchr Application Object. Instantiated for command-line mode
  # @see Launchr::CLI
  class Application

    def initialize *args, &blk
      Launchr::Config.init
      Launchr::Config.load_or_create
      
      @cli = Launchr::CLI.new
      Launchr::Config[:args] = @cli.parse
      Launchr::Config.import_args

      @commands = Launchr::Commands.new
      @commands.run

      Launchr::Config.save
    end
  end
end







