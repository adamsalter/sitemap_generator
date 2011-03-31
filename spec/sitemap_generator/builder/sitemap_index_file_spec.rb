require 'spec_helper'

context 'SitemapGenerator::Builder::SitemapIndexFile' do
  before :each do
    @loc = SitemapGenerator::SitemapLocation.new(:public_path => '/public/', :sitemaps_path => 'test/', :host => 'http://example.com/')
    @s = SitemapGenerator::Builder::SitemapIndexFile.new(:location => @loc)
  end

  it "should return the URL" do
    @s.location.url.should == 'http://example.com/test/sitemap_index.xml.gz'
  end

  it "should return the path" do
    @s.location.path.should == '/public/test/sitemap_index.xml.gz'
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
  
  it "filename should default to sitemap_index" do
    @s.filename.should == 'sitemap_index.xml.gz'
  end
  
  it "should set the filename base" do
    @s.filename = 'xxx'
    @s.filename.should == 'xxx_index.xml.gz'
  end
end
