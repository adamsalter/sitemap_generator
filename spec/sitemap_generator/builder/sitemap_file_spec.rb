require 'spec_helper'

describe 'SitemapGenerator::Builder::SitemapFile' do
  before :each do
    @loc = SitemapGenerator::SitemapLocation.new(:public_path => '/public/', :sitemaps_path => 'test/', :host => 'http://example.com/')
    @s = SitemapGenerator::Builder::SitemapFile.new(:location => @loc)
  end

  it "should return the name of the sitemap file" do
    @s.location.filename.should == 'sitemap1.xml.gz'
  end

  it "should return the URL" do
    @s.location.url.should == 'http://example.com/test/sitemap1.xml.gz'
  end

  it "should return the path" do
    @s.location.path.should == '/public/test/sitemap1.xml.gz'
  end

  it "should be empty" do
    @s.empty?.should be_true
    @s.link_count.should == 0
  end

  it "should not have a last modification data" do
    @s.lastmod.should be_nil
  end

  it "should not be finalized" do
    @s.finalized?.should be_false
  end

  it "should set the filename base" do
    @s.filename = 'xxx'
    @s.location.filename.should == 'xxx1.xml.gz'
  end

  describe "next" do
    before :each do
      @orig_s = @s
      @s = @s.next
    end

    it "should have the next filename in the sequence" do
      @s.location.filename.should == 'sitemap2.xml.gz'
    end

    it "should inherit the same options" do
      @s.location.url.should == 'http://example.com/test/sitemap2.xml.gz'
      @s.location.path.should == '/public/test/sitemap2.xml.gz'
    end

    it "should duplicate the location" do
      @s.location.should_not be(@orig_s.location)
    end
  end
end
