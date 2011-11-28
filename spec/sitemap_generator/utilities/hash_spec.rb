require "spec_helper"
require 'sitemap_generator/core_ext/hash/keys'

describe Hash do
  describe "assert_valid_keys" do
    it "should raise" do
      lambda do
        { :failore => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ])
        { :failore => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny)
      end.should raise_error(ArgumentError, "Unknown key(s): failore")
    end

    it "should not raise" do
      lambda do
        { :failure => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ])
        { :failure => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny)
      end.should_not raise_error
    end
  end

  describe "keys" do
    before :each do
      @strings = { 'a' => 1, 'b' => 2 }
      @symbols = { :a  => 1, :b  => 2 }
      @mixed   = { :a  => 1, 'b' => 2 }
      @fixnums = {  0  => 1,  1  => 2 }
      if RUBY_VERSION < '1.9.0'
        @illegal_symbols = { "\0" => 1, "" => 2, [] => 3 }
      else
        @illegal_symbols = { [] => 3 }
      end
    end

    it "should respond to new methods" do
      h = {}
      h.respond_to?(:symbolize_keys)
      h.respond_to?(:symbolize_keys!)
      h.respond_to?(:stringify_keys)
      h.respond_to?(:stringify_keys!)
    end

    it "should symbolize_keys" do
      @symbols.symbolize_keys.should == @symbols
      @strings.symbolize_keys.should == @symbols
      @mixed.symbolize_keys.should == @symbols
    end

    it "should symbolize_keys!" do
      @symbols.dup.symbolize_keys!.should == @symbols
      @strings.dup.symbolize_keys!.should == @symbols
      @mixed.dup.symbolize_keys!.should == @symbols
    end

    it "should symbolize_keys_preserves_keys_that_cant_be_symbolized" do
      @illegal_symbols.symbolize_keys.should == @illegal_symbols
      @illegal_symbols.dup.symbolize_keys!.should == @illegal_symbols
    end

    it "should symbolize_keys_preserves_fixnum_keys" do
      @fixnums.symbolize_keys.should == @fixnums
      @fixnums.dup.symbolize_keys!.should == @fixnums
    end

    it "should stringify_keys" do
      @symbols.stringify_keys.should == @strings
      @strings.stringify_keys.should == @strings
      @mixed.stringify_keys.should == @strings
    end

    it "should stringify_keys!" do
      @symbols.dup.stringify_keys!.should == @strings
      @strings.dup.stringify_keys!.should == @strings
      @mixed.dup.stringify_keys!.should == @strings
    end
  end
end
