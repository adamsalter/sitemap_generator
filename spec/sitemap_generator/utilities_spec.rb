require 'spec_helper'

describe SitemapGenerator::Utilities do

  describe "assert_valid_keys" do
    it "should raise error on invalid keys" do
      lambda {
        SitemapGenerator::Utilities.assert_valid_keys({ :name => "Rob", :years => "28" }, :name, :age)
      }.should raise_exception(ArgumentError)
      lambda {
        SitemapGenerator::Utilities.assert_valid_keys({ :name => "Rob", :age => "28" }, "name", "age")
      }.should raise_exception(ArgumentError)
    end

    it "should not raise error on valid keys" do
      lambda {
        SitemapGenerator::Utilities.assert_valid_keys({ :name => "Rob", :age => "28" }, :name, :age)
      }.should_not raise_exception

      lambda {
        SitemapGenerator::Utilities.assert_valid_keys({ :name => "Rob" }, :name, :age)
      }.should_not raise_exception
    end
  end

  describe "titleize" do
    it "should titleize words and replace underscores" do
      SitemapGenerator::Utilities.titleize('google').should == 'Google'
      SitemapGenerator::Utilities.titleize('amy_and_jon').should == 'Amy And Jon'
    end
  end

  describe "truthy?" do
    it "should be truthy" do
      ['1', 1, 't', 'true', true].each do |value|
        SitemapGenerator::Utilities.truthy?(value).should be_true
      end
      SitemapGenerator::Utilities.truthy?(nil).should be_false
    end
  end

  describe "falsy?" do
    it "should be falsy" do
      ['0', 0, 'f', 'false', false].each do |value|
        SitemapGenerator::Utilities.falsy?(value).should be_true
      end
      SitemapGenerator::Utilities.falsy?(nil).should be_false
    end
  end
end
