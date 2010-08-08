
require 'spec_helper'

describe Launchr::Config, "#default_backends" do
  describe "when the supplied sym is :brew" do
    it "should return the RubyCocoa backend" do
      Launchr::Config.default_backends(:brew).should == ["ruby_cocoa"] 
    end
  end

  describe "when the supplied sym is nil" do
    
    describe "when there is no File at the path CoreFoundationFramework" do
      it "should return DefaultBackendsAny" do
        File.stub(:exists?).with(Launchr::Config::CoreFoundationFramework).and_return(false)
        Launchr::Config.default_backends.should == Launchr::Config::DefaultBackendsAny
      end
    end

    describe "when there is a File at the path CoreFoundationFramework" do
      describe "when there is a File at the path RubycocoaFramework" do
        it "should return DefaultBackendsOsx + the RubyCocoa backend" do
          File.stub(:exists?).with(Launchr::Config::CoreFoundationFramework).and_return(true)
          File.stub(:exists?).with(Launchr::Config::RubycocoaFramework).and_return(true)
          Launchr::Config.default_backends.should == Launchr::Config::DefaultBackendsOsx + ["ruby_cocoa"]
        end
      end
      describe "when there is no File at the path RubycocoaFramework" do
        it "should return DefaultBackendsOsx" do
          File.stub(:exists?).with(Launchr::Config::CoreFoundationFramework).and_return(true)
          File.stub(:exists?).with(Launchr::Config::RubycocoaFramework).and_return(false)
          Launchr::Config.default_backends.should == Launchr::Config::DefaultBackendsOsx
        end
      end
    end
  end
end

