require 'spec_helper'

describe SitemapGenerator::Builder::SitemapUrl do
  let(:loc) {
    SitemapGenerator::SitemapLocation.new(
      :sitemaps_path => 'sitemaps/',
      :public_path => '/public',
      :host => 'http://test.com',
      :namer => SitemapGenerator::SitemapNamer.new(:sitemap)
    )}
  let(:sitemap_file) { SitemapGenerator::Builder::SitemapFile.new(loc) }

  it "should build urls for sitemap files" do
    url = SitemapGenerator::Builder::SitemapUrl.new(sitemap_file)
    url[:loc].should == 'http://test.com/sitemaps/sitemap1.xml.gz'
  end

  it "lastmod should default to the last modified date for sitemap files" do
    lastmod = 2.weeks.ago
    sitemap_file.expects(:lastmod).returns(lastmod)
    url = SitemapGenerator::Builder::SitemapUrl.new(sitemap_file)
    url[:lastmod].should == lastmod
  end

  it "should support subdirectory routing" do
    url = SitemapGenerator::Builder::SitemapUrl.new('/profile', :host => 'http://example.com/subdir/')
    url[:loc].should == 'http://example.com/subdir/profile'
    url = SitemapGenerator::Builder::SitemapUrl.new('profile', :host => 'http://example.com/subdir/')
    url[:loc].should == 'http://example.com/subdir/profile'
    url = SitemapGenerator::Builder::SitemapUrl.new('/deep/profile/', :host => 'http://example.com/subdir/')
    url[:loc].should == 'http://example.com/subdir/deep/profile/'
    url = SitemapGenerator::Builder::SitemapUrl.new('/deep/profile', :host => 'http://example.com/subdir')
    url[:loc].should == 'http://example.com/subdir/deep/profile'
    url = SitemapGenerator::Builder::SitemapUrl.new('deep/profile', :host => 'http://example.com/subdir')
    url[:loc].should == 'http://example.com/subdir/deep/profile'
    url = SitemapGenerator::Builder::SitemapUrl.new('deep/profile/', :host => 'http://example.com/subdir/')
    url[:loc].should == 'http://example.com/subdir/deep/profile/'
    url = SitemapGenerator::Builder::SitemapUrl.new('/', :host => 'http://example.com/subdir/')
    url[:loc].should == 'http://example.com/subdir/'
  end

  it "should not fail on a nil path segment" do
    lambda do
      SitemapGenerator::Builder::SitemapUrl.new(nil, :host => 'http://example.com')[:loc].should == 'http://example.com'
    end.should_not raise_error
  end

  it "should support a :videos option" do
    loc = SitemapGenerator::Builder::SitemapUrl.new('', :host => 'http://test.com', :videos => [1,2,3])
    loc[:videos].should == [1,2,3]
  end

  it "should support a singular :video option" do
    loc = SitemapGenerator::Builder::SitemapUrl.new('', :host => 'http://test.com', :video => 1)
    loc[:videos].should == [1]
  end

  it "should support an array :video option" do
    loc = SitemapGenerator::Builder::SitemapUrl.new('', :host => 'http://test.com', :video => [1,2], :videos => [3,4])
    loc[:videos].should == [3,4,1,2]
  end

  it "should not fail if invalid characters are used in the URL" do
    special = ':$&+,;:=?@'
    url = SitemapGenerator::Builder::SitemapUrl.new("/#{special}", :host => "http://example.com/#{special}/")
    url[:loc].should == "http://example.com/#{special}/#{special}"
  end
end
