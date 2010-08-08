
require 'spec_helper'
require "launchr/cli"

describe Launchr::CLI, "#launchr_cli_options" do
  it "should call option to define cli options" do
    Launchr::CLI.should_receive(:option).at_least(:once)
    Launchr::CLI.launchr_cli_options
  end
end

describe Launchr::CLI, "#parse" do
  before(:each) do
    @cli = Launchr::CLI.new
    @cli.stub(:parse_options)
    @cli.stub(:config)
    @argv = ["arg1","arg2","etc..."]
  end

  it "should follow the default calling path" do
    @cli.should_receive(:parse_options).with(@argv)
    @cli.should_receive(:config)
    @cli.parse(@argv)
  end
end