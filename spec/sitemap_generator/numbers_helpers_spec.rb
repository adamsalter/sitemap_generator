require 'spec_helper'
require 'sitemap_generator/interpreter'

describe "Numbers helpers" do

  it "should not fail for SitemapFile" do
    File.expects(:size?).returns(100000)
    sm = SitemapGenerator::Builder::SitemapFile.new
    sm.expects(:number_to_human_size).raises(ArgumentError).at_least_once
    lambda { sm.summary }.should_not raise_exception(ArgumentError)
  end

  it "should not fail for SitemapIndexFile" do
    File.expects(:size?).returns(100000)
    sm = SitemapGenerator::Builder::SitemapIndexFile.new
    sm.expects(:number_to_human_size).raises(ArgumentError).at_least_once
    lambda { sm.summary }.should_not raise_exception(ArgumentError)
  end
end