require 'spec_helper'

describe SitemapGenerator::Builder::SitemapIndexUrl do
  before :all do
    @host = 'http://example.com/test/'
    @loc = SitemapGenerator::SitemapLocation.new(
      :sitemaps_path => 'sitemaps/',
      :public_path => '/public',
      :host => 'http://test.com' 
    )
    @s = SitemapGenerator::Builder::SitemapIndexFile.new(:location => @loc)
  end

  it "should return the correct url" do
    @u = SitemapGenerator::Builder::SitemapUrl.new(@s)
    @u[:loc].should == 'http://test.com/sitemaps/sitemap_index.xml.gz'
  end
end