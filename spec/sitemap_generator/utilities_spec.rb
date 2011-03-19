require 'spec_helper'

describe SitemapGenerator::Utilities do

  describe "rails3?" do
    tests = {
      :nil => false,
      '2.3.11' => false,
      '3.0.1' => true,
      '3.0.11' => true
    }
    it "should identify the rails version correctly" do
      tests.each do |version, result|
        Rails.expects(:version).returns(version)
        SitemapGenerator::Utilities.rails3?.should == result
      end
    end
  end

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
end