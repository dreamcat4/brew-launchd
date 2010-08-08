
require 'spec_helper'
require "launchr/application"

describe Launchr::Application, "#initialize" do
  before(:each) do
    @cli = Launchr::CLI.new
    Launchr::CLI.stub(:new).and_return(@cli)
    @mixlib_cli_args = {}
    @cli.stub(:parse).and_return(@mixlib_cli_args)

    @commands = Launchr::Commands.new
    Launchr::Commands.stub(:new).and_return(@commands)

    @application = Launchr::Application.new
  end

  it "should set Launchr::Config[:args] to a Hash" do
    Launchr::Config[:args].should be_a_kind_of(Hash)
  end

  it "should set @cli to a Launchr::CLI object" do
    @application.instance_eval { @cli }.should be_a_kind_of(Launchr::CLI)
  end
  
  it "should set @commands to a Launchr::Commands object" do
    @application.instance_eval { @commands }.should be_a_kind_of(Launchr::Commands)
  end

  it "should follow the default calling path" do
    @cli.should_receive(:parse)
    Launchr::Config.should_receive(:[]=).with(:args,@mixlib_cli_args)
    @commands.should_receive(:run)
    @application.instance_eval { initialize }
  end
end

