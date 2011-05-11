require 'spec_helper'

describe SitemapGenerator::LinkSet do
  before :each do
    @default_host = 'http://example.com'
    @ls = SitemapGenerator::LinkSet.new
  end

  describe "initializer options" do
    options = [:public_path, :sitemaps_path, :default_host, :filename]
    values = [File.expand_path(SitemapGenerator.app.root + 'tmp/'), 'mobile/', 'http://myhost.com', :xxx]

    options.zip(values).each do |option, value|
      it "should set #{option} to #{value}" do
        @ls = SitemapGenerator::LinkSet.new(option => value)
        @ls.send(option).should == value
      end
    end
  end

  describe "default options" do
    default_options = {
      :filename => :sitemap,
      :sitemaps_path => nil,
      :public_path => SitemapGenerator.app.root + 'public/',
      :default_host => nil,
      :include_index => true,
      :include_root => true
    }

    default_options.each do |option, value|
      it "#{option} should default to #{value}" do
        @ls.send(option).should == value
      end
    end
  end

  describe "include_root include_index option" do
    it "should not include the root url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :include_root => false)
      @ls.include_root.should be_false
      @ls.include_index.should be_true
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 1
    end

    it "should not include the sitemap index url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :include_index => false)
      @ls.include_root.should be_true
      @ls.include_index.should be_false
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 1
    end

    it "should not include the root url or the sitemap index url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :include_root => false, :include_index => false)
      @ls.include_root.should be_false
      @ls.include_index.should be_false
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 0
    end
  end

  describe "sitemaps public_path" do
    it "should default to public/" do
      @ls.public_path.should ==  SitemapGenerator.app.root + 'public/'
      @ls.sitemap.location.public_path.should == @ls.public_path
      @ls.sitemap_index.location.public_path.should == @ls.public_path
    end

    it "should change when the public_path is changed" do
      @ls.public_path = 'tmp'
      @ls.sitemap.location.public_path.should == @ls.public_path
      @ls.sitemap_index.location.public_path.should == @ls.public_path
    end
  end

  describe "sitemaps url" do
    it "should change when the default_host is changed" do
      @ls.default_host = 'http://one.com'
      @ls.default_host.should == 'http://one.com'
      @ls.default_host.should == @ls.sitemap.location.host
      @ls.default_host.should == @ls.sitemap_index.location.host
    end

    it "should change when the sitemaps_path is changed" do
      @ls.default_host = 'http://one.com'
      @ls.sitemaps_path = 'sitemaps/'
      @ls.sitemap.location.url.should == 'http://one.com/sitemaps/sitemap1.xml.gz'
      @ls.sitemap_index.location.url.should == 'http://one.com/sitemaps/sitemap_index.xml.gz'
    end
  end

  describe "ping search engines" do
    before do
      @ls = SitemapGenerator::LinkSet.new :default_host => 'http://one.com'
    end

    it "should not fail" do
      @ls.expects(:open).at_least_once
      lambda { @ls.ping_search_engines }.should_not raise_error
    end
  end

  describe "verbose" do
    before do
      @ls = SitemapGenerator::LinkSet.new(:default_host => 'http://one.com')
    end

    it "should default to false" do
      @ls.verbose.should be_false
    end

    it "should be set as an initialize option" do
      SitemapGenerator::LinkSet.new(:default_host => 'http://one.com', :verbose => true).verbose.should be_true
    end

    it "should be set as an accessor" do
      @ls.verbose = true
      @ls.verbose.should be_true
    end
  end

  describe "when finalizing" do
    before do
      @ls = SitemapGenerator::LinkSet.new(:default_host => 'http://one.com', :verbose => true)
    end

    it "should output summary lines" do
      @ls.sitemap.expects(:finalize!)
      @ls.sitemap.expects(:summary)
      @ls.sitemap_index.expects(:finalize!)
      @ls.sitemap_index.expects(:summary)
      @ls.finalize!
    end
  end

  describe "sitemaps host" do
    before do
      @new_host = 'http://wowza.com'
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host)
    end

    it "should have a host" do
      @ls.default_host = @default_host
      @ls.default_host.should == @default_host
    end

    it "should default to default host" do
      @ls.sitemaps_host.should == @ls.default_host
    end

    it "should update the host in the sitemaps when changed" do
      @ls.sitemaps_host = @new_host
      @ls.sitemaps_host.should == @new_host
      @ls.sitemap.location.host.should == @ls.sitemaps_host
      @ls.sitemap_index.location.host.should == @ls.sitemaps_host
    end

    it "should not change the default host for links" do
      @ls.sitemaps_host = @new_host
      @ls.default_host.should == @default_host
    end
  end

  describe "with a sitemap index specified" do
    before :each do
      @index = SitemapGenerator::Builder::SitemapIndexFile.new(:host => @default_host)
      @ls = SitemapGenerator::LinkSet.new(:sitemap_index => @index, :sitemaps_host => 'http://newhost.com')
    end

    it "should not modify the index" do
      @ls.filename = :newname
      @ls.sitemap.location.filename.should =~ /newname/
      @ls.sitemap_index.location.filename =~ /sitemap_index/
    end

    it "should not modify the index" do
      @ls.sitemaps_host = 'http://newhost.com'
      @ls.sitemap.location.host.should == 'http://newhost.com'
      @ls.sitemap_index.location.host.should == @default_host
    end

    it "should not finalize the index" do
      @ls.send(:finalize_sitemap_index!)
      @ls.sitemap_index.finalized?.should be_false
    end
  end

  describe "new group" do
    before :each do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host)
    end

    it "should return a LinkSet" do
      @ls.group.should be_a(SitemapGenerator::LinkSet)
    end

    it "should share the sitemap_index" do
      @ls.group.sitemap_index.should == @ls.sitemap_index
    end

    it "should protect the sitemap_index" do
      @ls.group.instance_variable_get(:@protect_index).should be_true
    end

    it "should not set the public_path" do
      @ls.group(:public_path => 'new/path/').public_path.to_s.should == @ls.public_path.to_s
    end

    it "include_root should default to false" do
      @ls.group.include_root.should be_false
    end

    it "include_index should default to false" do
      @ls.group.include_index.should be_false
    end

    it "should set include_root" do
      @ls.group(:include_root => true).include_root.should be_true
    end

    it "should set include_index" do
      @ls.group(:include_index => true).include_index.should be_true
    end

    it "filename should be inherited" do
      @ls.group.filename.should == :sitemap
    end

    it "should set filename but not modify the index" do
      @ls.group(:filename => :newname).filename.should == :newname
      @ls.sitemap_index.location.filename.should =~ /sitemap_index/
    end

    it "should finalize the sitemaps if a block is passed" do
      @group = @ls.group
      @group.sitemap.finalized?.should be_false
    end

    it "should only finalize the sitemaps if a block is passed" do
      @group = @ls.group
      @group.sitemap.finalized?.should be_false
    end

    it "should set the sitemaps_path" do
      @ls.group(:sitemaps_path => 'new/path/').sitemaps_path.should == 'new/path/'
    end

    it "should set the sitemaps_host" do
      @host = 'http://sitemaphost.com'
      @ls.group(:sitemaps_host => @host).sitemaps_host.should == @host
    end

    it "should inherit the verbose option" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :verbose => true)
      @ls.group.verbose.should be_true
    end

    it "should set the verbose option" do
      @ls.group(:verbose => !!@ls.verbose).verbose.should == !!@ls.verbose
    end

    it "should set the default_host" do
      @ls.group.default_host.should == @default_host
    end

    it "should not finalize the sitemap if a group is created" do
      @ls.create { group {} }
      @ls.sitemap.empty?.should be_true
      @ls.sitemap.finalized?.should be_false
    end

    describe "sitemaps_host" do
      it "should finalize the sitemap if it is the only option" do
        @ls.expects(:finalize_sitemap!)
        @ls.group(:sitemaps_host => 'http://test.com') {}
      end

      {
        :sitemaps_path => 'en/',
        :filename => :example,
        :sitemaps_namer => SitemapGenerator::SitemapNamer.new(:sitemap)
      }.each do |k, v|
        it "should not finalize the sitemap if #{k} is present" do
          @ls.expects(:finalize_sitemap!).never
          @ls.group(k => v) { }
        end
      end
    end
  end

  describe "after create" do
    before :each do
      @ls = SitemapGenerator::LinkSet.new :default_host => @default_host
    end

    it "should finalize the sitemap index" do
      @ls.create {}
      @ls.sitemap_index.finalized?.should be_true
    end

    it "should finalize the sitemap" do
      @ls.create {}
      @ls.sitemap.finalized?.should be_true
    end

    it "should not finalize the sitemap if a group was created" do
      @ls.instance_variable_set(:@created_group, true)
      @ls.send(:finalize_sitemap!)
      @ls.sitemap.finalized?.should be_false
    end
  end
end
