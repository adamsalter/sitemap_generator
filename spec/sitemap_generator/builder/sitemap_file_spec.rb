require 'spec_helper'

context 'SitemapGenerator::Builder::SitemapFile' do
  before :each do
    @s = SitemapGenerator::Builder::SitemapFile.new('public/', '/test/')
  end

  it "should return the URL for the sitemap file" do
    @s.full_url.should == 'http://example.com/test/'
  end
  
  it "should return the URL for the sitemap file" do
    @s.full_path.should == 'public/test/'
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
