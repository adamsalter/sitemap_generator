require 'spec_helper'

describe SitemapGenerator::Utilities do
  describe "rounding" do
    let(:utils) { SitemapGenerator::Utilities }

    it "should round for positive number" do
      utils.round(1.4)      .should == 1
      utils.round(1.6)     .should == 2
      utils.round(1.6, 0)  .should == 2
      utils.round(1.4, 1)  .should == 1.4
      utils.round(1.4, 3)  .should == 1.4
      utils.round(1.45, 1) .should == 1.5
      utils.round(1.445, 2).should == 1.45
      # Demonstrates a bug in the round method
      # utils.round(9.995, 2).should == 10 
    end

    it "should round for negative number" do
      utils.round(-1.4)    .should == -1
      utils.round(-1.6)    .should == -2
      utils.round(-1.4, 1) .should == -1.4
      utils.round(-1.45, 1).should == -1.5
    end

    it "should round with negative precision" do
      utils.round(123456.0, -1).should == 123460.0
      utils.round(123456.0, -2).should == 123500.0
    end
  end
end
