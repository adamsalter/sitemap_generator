require 'spec_helper'

describe SitemapGenerator::SitemapLocation do
  before :all do
    @default_host = 'http://example.com'
  end

  it "public_path should default to the public directory in the application root" do
    @l = SitemapGenerator::SitemapLocation.new
    @l.public_path.should == SitemapGenerator.app.root + 'public/'
  end

  it "should have a default namer" do
    @l = SitemapGenerator::SitemapLocation.new
    @l[:namer].should_not be_nil
    @l[:filename].should be_nil
    @l.filename.should == 'sitemap1.xml.gz'
  end

  it "should require a filename" do
    @l = SitemapGenerator::SitemapLocation.new
    @l[:filename] = nil
    lambda {
      @l.filename.should be_nil
    }.should raise_error
  end

  it "should require a namer" do
    @l = SitemapGenerator::SitemapLocation.new
    @l[:namer] = nil
    lambda {
      @l.filename.should be_nil
    }.should raise_error
  end
  
  it "should require a host" do
    @l = SitemapGenerator::SitemapLocation.new(:filename => nil, :namer => nil)
    lambda {
      @l.host.should be_nil
    }.should raise_error
  end

  it "should accept a Namer option" do
    @namer = SitemapGenerator::SitemapNamer.new(:xxx)
    @l = SitemapGenerator::SitemapLocation.new(:namer => @namer)
    @l.filename.should == @namer.to_s
  end

  it "should protect the filename from further changes in the Namer" do
    @namer = SitemapGenerator::SitemapNamer.new(:xxx)
    @l = SitemapGenerator::SitemapLocation.new(:namer => @namer)
    @l.filename.should == @namer.to_s
    @namer.next
    @l.filename.should == @namer.previous.to_s
  end

  it "should allow changing the namer" do
    @namer1 = SitemapGenerator::SitemapNamer.new(:xxx)
    @l = SitemapGenerator::SitemapLocation.new(:namer => @namer1)
    @l.filename.should == @namer1.to_s
    @namer2 = SitemapGenerator::SitemapNamer.new(:yyy)
    @l[:namer] = @namer2
    @l.filename.should == @namer2.to_s
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
        :directory => '/public/system/sitemaps/en',
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

  describe "when duplicated" do
    it "should not inherit some objects" do
      @l = SitemapGenerator::SitemapLocation.new(:filename => 'xxx', :host => @default_host, :public_path => 'public/')
      @l.url.should == @default_host+'/xxx'
      @l.public_path.to_s.should == 'public/'
      dup = @l.dup
      dup.url.should == @l.url
      dup.url.should_not be(@l.url)
      dup.public_path.to_s.should == @l.public_path.to_s
      dup.public_path.should_not be(@l.public_path)
    end
  end
end

describe SitemapGenerator::SitemapIndexLocation do
  it "should have a default namer" do
    @l = SitemapGenerator::SitemapIndexLocation.new
    @l[:namer].should_not be_nil
    @l[:filename].should be_nil
    @l.filename.should == 'sitemap_index.xml.gz'
  end
end
