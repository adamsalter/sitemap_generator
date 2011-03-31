require 'spec_helper'

describe SitemapGenerator::Builder::SitemapUrl do
  before :all do
    @host = 'http://example.com/test/'
    @loc = SitemapGenerator::SitemapLocation.new(
      :sitemaps_path => 'sitemaps/',
      :public_path => '/public',
      :filename => 'sitemap1.xml.gz',
      :host => 'http://test.com' 
    )
    @s = SitemapGenerator::Builder::SitemapFile.new(:location => @loc)
  end

  it "should return the correct url" do
    @u = SitemapGenerator::Builder::SitemapUrl.new(@s)
    @u[:loc].should == 'http://test.com/sitemaps/sitemap1.xml.gz'
  end
end