require 'spec_helper'
require 'sitemap_generator/core_ext/float/rounding'

describe Float do
  describe "rounding" do
    it "should round for positive number" do
      1.4.round     .should == 1
      1.6.round     .should == 2
      1.6.round(0)  .should == 2
      1.4.round(1)  .should == 1.4
      1.4.round(3)  .should == 1.4
      1.45.round(1) .should == 1.5
      1.445.round(2).should == 1.45
    end

    it "should round for negative number" do
      -1.4.round    .should == -1
      -1.6.round    .should == -2
      -1.4.round(1) .should == -1.4
      -1.45.round(1).should == -1.5
    end

    it "should round with negative precision" do
      123456.0.round(-1).should == 123460.0
      123456.0.round(-2).should == 123500.0
    end
  end
end
