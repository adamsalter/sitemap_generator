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

  describe "as_array" do
    it "should return an array unchanged" do
      SitemapGenerator::Utilities.as_array([]).should == []
      SitemapGenerator::Utilities.as_array([1]).should == [1]
      SitemapGenerator::Utilities.as_array([1,2,3]).should == [1,2,3]
    end

    it "should return empty array on nil" do
      SitemapGenerator::Utilities.as_array(nil).should == []
    end

    it "should make array of item otherwise" do
      SitemapGenerator::Utilities.as_array('').should == ['']
      SitemapGenerator::Utilities.as_array(1).should == [1]
      SitemapGenerator::Utilities.as_array('hello').should == ['hello']
      SitemapGenerator::Utilities.as_array({}).should == [{}]
    end
  end

  describe "append_slash" do
    SitemapGenerator::Utilities.append_slash('').should == ''
    SitemapGenerator::Utilities.append_slash(nil).should == ''
    SitemapGenerator::Utilities.append_slash(Pathname.new('')).should == ''
    SitemapGenerator::Utilities.append_slash('tmp').should == 'tmp/'
    SitemapGenerator::Utilities.append_slash(Pathname.new('tmp')).should == 'tmp/'
    SitemapGenerator::Utilities.append_slash('tmp/').should == 'tmp/'
    SitemapGenerator::Utilities.append_slash(Pathname.new('tmp/')).should == 'tmp/'
  end

  describe "ellipsis" do
    it "should not modify when less than or equal to max" do
      (1..10).each do |i|
        string = 'a'*i
        SitemapGenerator::Utilities.ellipsis(string, 10).should == string
      end
    end

    it "should replace last 3 characters with ellipsis when greater than max" do
      (1..5).each do |i|
        string = 'aaaaa' + 'a'*i
        SitemapGenerator::Utilities.ellipsis(string, 5).should == 'aa...'
      end
    end

    it "should not freak out when string too small" do
      SitemapGenerator::Utilities.ellipsis('a', 1).should == 'a'
      SitemapGenerator::Utilities.ellipsis('aa', 1).should == '...'
      SitemapGenerator::Utilities.ellipsis('aaa', 1).should == '...'
    end
  end
end
