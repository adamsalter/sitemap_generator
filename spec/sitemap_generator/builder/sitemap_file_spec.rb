require 'spec_helper'

context 'SitemapGenerator::Builder::SitemapFile' do
  before :each do
    @s = SitemapGenerator::Builder::SitemapFile.new(:directory => 'public/test/', :host => 'http://example.com/test/')
  end

  it "should return the URL for the sitemap file" do
    @s.url.should == 'http://example.com/test/sitemap1.xml.gz'
  end

  it "should return the URL for the sitemap file" do
    @s.path.should == 'public/test/sitemap1.xml.gz'
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
end
