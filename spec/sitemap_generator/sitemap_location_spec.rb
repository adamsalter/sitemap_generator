require 'spec_helper'

describe SitemapGenerator::SitemapLocation do
  let(:default_host) { 'http://example.com' }
  let(:location)     { SitemapGenerator::SitemapLocation.new }
  
  it "public_path should default to the public directory in the application root" do
    location.public_path.should == SitemapGenerator.app.root + 'public/'
  end

  it "should have a default namer" do
    location[:namer].should_not be_nil
    location[:filename].should be_nil
    location.filename.should == 'sitemap1.xml.gz'
  end

  it "should require a filename" do
    location[:filename] = nil
    lambda {
      location.filename.should be_nil
    }.should raise_error
  end

  it "should require a namer" do
    location[:namer] = nil
    lambda {
      location.filename.should be_nil
    }.should raise_error
  end

  it "should require a host" do
    location = SitemapGenerator::SitemapLocation.new(:filename => nil, :namer => nil)
    lambda {
      location.host.should be_nil
    }.should raise_error
  end

  it "should accept a Namer option" do
    @namer = SitemapGenerator::SitemapNamer.new(:xxx)
    location = SitemapGenerator::SitemapLocation.new(:namer => @namer)
    location.filename.should == @namer.to_s
  end

  it "should protect the filename from further changes in the Namer" do
    @namer = SitemapGenerator::SitemapNamer.new(:xxx)
    location = SitemapGenerator::SitemapLocation.new(:namer => @namer)
    location.filename.should == @namer.to_s
    @namer.next
    location.filename.should == @namer.previous.to_s
  end

  it "should allow changing the namer" do
    @namer1 = SitemapGenerator::SitemapNamer.new(:xxx)
    location = SitemapGenerator::SitemapLocation.new(:namer => @namer1)
    location.filename.should == @namer1.to_s
    @namer2 = SitemapGenerator::SitemapNamer.new(:yyy)
    location[:namer] = @namer2
    location.filename.should == @namer2.to_s
  end

  describe "testing options and #with" do

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
        :directory => '/public/system/sitemaps/en',
        :path => '/public/system/sitemaps/en/sitemap1.xml.gz',
        :path_in_public => 'sitemaps/en/sitemap1.xml.gz'
      }]
    ]
    tests.each do |opts, returns|
      returns.each do |method, value|
        it "#{method} should return #{value}" do
          location.with(opts).send(method).should == value
        end
      end
    end
  end

  describe "when duplicated" do
    it "should not inherit some objects" do
      location = SitemapGenerator::SitemapLocation.new(:filename => 'xxx', :host => default_host, :public_path => 'public/')
      location.url.should == default_host+'/xxx'
      location.public_path.to_s.should == 'public/'
      dup = location.dup
      dup.url.should == location.url
      dup.url.should_not be(location.url)
      dup.public_path.to_s.should == location.public_path.to_s
      dup.public_path.should_not be(location.public_path)
    end
  end

  describe "filesize" do
    it "should read the size of the file at path" do
      location.expects(:path).returns('/somepath')
      File.expects(:size?).with('/somepath')
      location.filesize
    end
  end
end

describe SitemapGenerator::SitemapIndexLocation do
  let(:location)     { SitemapGenerator::SitemapIndexLocation.new }

  it "should have a default namer" do
    location = SitemapGenerator::SitemapIndexLocation.new
    location[:namer].should_not be_nil
    location[:filename].should be_nil
    location.filename.should == 'sitemap.xml.gz'
  end
end
