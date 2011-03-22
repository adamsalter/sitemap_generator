require 'spec_helper'

context 'SitemapGenerator::Builder::SitemapIndexFile' do
  before :each do
    @s = SitemapGenerator::Builder::SitemapIndexFile.new(:directory => 'public/test/', :host => 'http://example.com/test/')
  end

  it "should return the URL" do
    @s.url.should == 'http://example.com/test/sitemap_index.xml.gz'
  end

  it "should return the path" do
    @s.path.should == 'public/test/sitemap_index.xml.gz'
  end

  it "should be empty" do
    debugger
    @s.empty?.should be_true
    @s.link_count.should == 0
  end

  it "should not have a last modification data" do
    @s.lastmod.should be_nil
  end

  it "should not be finalized" do
    @s.finalized?.should be_false
  end
end
