require 'spec_helper'

describe SitemapGenerator::SitemapLocation do
  it "public_path should default to the public directory in the application root" do
    @l = SitemapGenerator::SitemapLocation.new
    @l.public_path.should == SitemapGenerator.app.root + 'public/'
  end

  it "should require a filename" do
    @l = SitemapGenerator::SitemapLocation.new
    lambda {
      @l.filename.should be_nil  
    }.should raise_error
  end

  it "should require a host" do
    @l = SitemapGenerator::SitemapLocation.new
    lambda {
      @l.host.should be_nil
    }.should raise_error
  end

  describe "testing options and #with" do
    before :all do
      @l = SitemapGenerator::SitemapLocation.new
    end
    
    # Array of tuples with instance options and expected method return values
    tests = [
      [{
        :sitemaps_path => nil,
        :public_path => '/public',
        :filename => 'sitemap1.xml.gz',
        :host => 'http://test.com' },
      { :url => 'http://test.com/sitemap1.xml.gz',
        :directory => '/public',
        :path => '/public/sitemap1.xml.gz',
        :path_in_public => 'sitemap1.xml.gz'
      }],
      [{
        :sitemaps_path => 'sitemaps/en/',
        :public_path => '/public/system/',
        :filename => 'sitemap1.xml.gz',
        :host => 'http://test.com/plus/extra/' },
      { :url => 'http://test.com/plus/extra/sitemaps/en/sitemap1.xml.gz',
        :directory => '/public/system/sitemaps/en/',
        :path => '/public/system/sitemaps/en/sitemap1.xml.gz',
        :path_in_public => 'sitemaps/en/sitemap1.xml.gz'
      }]
    ]
    tests.each do |opts, returns|
      returns.each do |method, value|
        it "#{method} should return #{value}" do
          @l.with(opts).send(method).should == value
        end
      end
    end
  end
end
