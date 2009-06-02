require File.dirname(__FILE__) + '/../spec_helper'

describe "pancake stack configuration" do
  
  before(:each) do
    class ::FooStack < Pancake::Stack
    end
    FooStack.roots << Pancake.get_root(__FILE__)
  end
  
  after(:each) do
    clear_constants(:FooStack)
  end
  
  it "should provide access to the stack configuration" do
    FooStack.configuration.class.should inherit_from(Pancake::Configuration::Base)
  end
  
  it "should allow me to set defaults on a stack" do
    FooStack.configuration do 
      default :foo, :bar
      default :bar, "Foo Bar Man"
    end
    FooStack.configuration.foo.should == :bar
    FooStack.configuration.bar.should == "Foo Bar Man"
  end

  it "should provide access to the roots of the stack through the config object" do
    FooStack.roots.should == [Pancake.get_root(__FILE__)]
    FooStack.configuration.roots.should == [Pancake.get_root(__FILE__)]
  end
  
  it "should allow me to extend the configuration" do
    class Pancake::Stack::Configuration
      default :foo, :bar, "I am a foo default"
      default :bar do
        foobar
      end
      
      def foobar
        :foobar
      end
    end
    class FooBarStack < Pancake::Stack; end
    
    FooBarStack.configuration.foo.should == :bar
    FooBarStack.configuration.bar.should == :foobar
  end 
  
  describe "configurations" do
    before(:each) do
      Pancake.configuration.stacks.clear
    end
    
    it "should provide a configuration object for the stack" do
      app = FooStack.stack
      app.configuration.should be_an_instance_of(FooStack::Configuration)
    end
    
    it "should put a copy of the application at the stack identified by the class" do
      app = FooStack.stack
      Pancake.configuration.stacks[FooStack].should equal(app)
    end
    
    it "should allow me to set a configuration object manually" do
      config = FooStack::Configuration.new
      app = FooStack.stack(:config => config)
      app.configuration.should equal(config)
    end
    
    it "should allow me to have access to the configuration object when creating the stack through a block" do
      app = FooStack.stack do |config|
        config.foo = :foo
        config.bar = :bar
      end
      app.configuration.foo.should == :foo
      app.configuration.bar.should == :bar
    end
    
    it "should setup access to the configuration object through Pancakes configuration" do
      app = FooStack.stack
      Pancake.configuration.stacks[FooStack].should equal app
      Pancake.configuration.configs[FooStack].should equal app.configuration
    end
    
    it "should allow me to create a configuration with a label" do
      FooStack.configuration(:my_config).should be_an_instance_of(FooStack::Configuration)
      FooStack.configuration(:my_config).should_not equal(FooStack.configuration)
    end
    
    it "should create a stack with an app_name" do
      FooStack.stack(:app_name => "my.app.name")  
      Pancake.configuration.stacks[FooStack].should be_nil
      Pancake.configuration.stacks["my.app.name"].should be_an_instance_of(FooStack)
      Pancake.configuration.configs["my.app.name"].should be_an_instance_of(FooStack::Configuration)
    end
  end

end