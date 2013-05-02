require 'spec_helper'

describe SitemapGenerator::Builder::SitemapIndexUrl do
  let(:index) {
    SitemapGenerator::Builder::SitemapIndexFile.new(
      :sitemaps_path => 'sitemaps/',
      :host => 'http://test.com',
      :filename => 'sitemap_index.xml.gz'
    )
  }
  let(:url)  { SitemapGenerator::Builder::SitemapUrl.new(index) }

  it "should return the correct url" do
    url[:loc].should == 'http://test.com/sitemaps/sitemap_index.xml.gz'
  end

  it "should use the host from the index" do
    host = 'http://myexample.com'
    index.location.expects(:host).returns(host)
    url[:host].should == host
  end

  it "should use the public path for the link" do
    path = '/path'
    index.location.expects(:path_in_public).returns(path)
    url[:loc].should == 'http://test.com/path'
  end
end