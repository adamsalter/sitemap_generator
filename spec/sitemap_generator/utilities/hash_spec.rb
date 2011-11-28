require "spec_helper"

describe SitemapGenerator::Utilities do
  let(:utils) { SitemapGenerator::Utilities }

  describe "assert_valid_keys" do
    it "should raise" do
      lambda do
        utils.assert_valid_keys({ :failore => "stuff", :funny => "business" }, [ :failure, :funny])
        utils.assert_valid_keys({ :failore => "stuff", :funny => "business" }, :failure, :funny)
      end.should raise_error(ArgumentError, "Unknown key(s): failore")
    end

    it "should not raise" do
      lambda do
        utils.assert_valid_keys({ :failure => "stuff", :funny => "business" }, [ :failure, :funny ])
        utils.assert_valid_keys({ :failure => "stuff", :funny => "business" }, :failure, :funny)
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

    it "should symbolize_keys" do
      utils.symbolize_keys(@symbols).should == @symbols
      utils.symbolize_keys(@strings).should == @symbols
      utils.symbolize_keys(@mixed).should == @symbols
    end

    it "should symbolize_keys!" do
      utils.symbolize_keys!(@symbols.dup).should == @symbols
      utils.symbolize_keys!(@strings.dup).should == @symbols
      utils.symbolize_keys!(@mixed.dup).should == @symbols
    end

    it "should symbolize_keys_preserves_keys_that_cant_be_symbolized" do
      utils.symbolize_keys(@illegal_symbols).should == @illegal_symbols
      utils.symbolize_keys!(@illegal_symbols.dup).should == @illegal_symbols
    end

    it "should symbolize_keys_preserves_fixnum_keys" do
      utils.symbolize_keys(@fixnums).should == @fixnums
      utils.symbolize_keys!(@fixnums.dup).should == @fixnums
    end
  end
end
