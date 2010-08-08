
require 'spec_helper'
require "launchr/commands"

describe Launchr::Commands, "#run" do
  before(:each) do
    Launchr::Config[:args] = { :ruby_lib => true }
    @commands = Launchr::Commands.new
    @commands.stub(:ruby_lib)
  end
  it "should follow the default calling path" do
    Launchr::Commands::PriorityOrder.should_receive(:each).and_yield(:ruby_lib)
    Launchr::Config[:args].should_receive(:[]).with(:ruby_lib).and_return(true)
    Launchr::Config[:args].should_receive(:keys).and_return([:ruby_lib])
    Launchr::Config[:args].should_receive(:each).and_yield(:ruby_lib,true)
    @commands.run
  end
end


