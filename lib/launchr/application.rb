
require 'launchr/cli'
require 'launchr/commands'

module Launchr
  # The Launchr Application Object. Instantiated for command-line mode
  # @see Launchr::CLI
  class Application

    def initialize *args, &blk
      @cli = Launchr::CLI.new

      Launchr.load_default

      Launchr.config[:args] = @cli.parse
      Launchr.import_args

      @commands = Launchr::Commands.new
      @commands.run
    end
  end
end


