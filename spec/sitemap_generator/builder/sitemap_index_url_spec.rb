require 'spec_helper'

describe SitemapGenerator::Builder::SitemapIndexUrl do
  before :all do
    @s = SitemapGenerator::Builder::SitemapIndexFile.new(
      :sitemaps_path => 'sitemaps/',
      :host => 'http://test.com',
      :filename => 'sitemap_index.xml.gz'
    )
  end

  it "should return the correct url" do
    @u = SitemapGenerator::Builder::SitemapUrl.new(@s)
    @u[:loc].should == 'http://test.com/sitemaps/sitemap_index.xml.gz'
  end
end