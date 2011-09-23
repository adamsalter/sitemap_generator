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

    describe "general behaviour" do
      it "should return a LinkSet" do
        @ls.group.should be_a(SitemapGenerator::LinkSet)
      end

      it "should inherit the index" do
        @ls.group.sitemap_index.should == @ls.sitemap_index
      end

      it "should protect the sitemap_index" do
        @ls.group.instance_variable_get(:@protect_index).should be_true
      end

      it "should not allow chaning the public_path" do
        @ls.group(:public_path => 'new/path/').public_path.to_s.should == @ls.public_path.to_s
      end
    end

    describe "include_index" do
      it "should set the value" do
        @ls.group(:include_index => !@ls.include_index).include_index.should_not == @ls.include_index
      end

      it "should default to false" do
        @ls.group.include_index.should be_false
      end
    end

    describe "include_root" do
      it "should set the value" do
        @ls.group(:include_root => !@ls.include_root).include_root.should_not == @ls.include_root
      end

      it "should default to false" do
        @ls.group.include_root.should be_false
      end
    end

    describe "filename" do
      it "should inherit the value" do
        @ls.group.filename.should == :sitemap
      end

      it "should set the value" do
        group = @ls.group(:filename => :xxx)
        group.filename.should == :xxx
        group.sitemap.location.filename.should =~ /xxx/
      end
    end

    describe "verbose" do
      it "should inherit the value" do
        @ls.group.verbose.should == @ls.verbose
      end

      it "should set the value" do
        @ls.group(:verbose => !@ls.verbose).verbose.should_not == @ls.verbose
      end
    end

    describe "sitemaps_path" do
      it "should inherit the sitemaps_path" do
        group = @ls.group
        group.sitemaps_path.should == @ls.sitemaps_path
        group.sitemap.location.sitemaps_path.should == @ls.sitemap.location.sitemaps_path
      end

      it "should set the sitemaps_path" do
        path = 'new/path'
        group = @ls.group(:sitemaps_path => path)
        group.sitemaps_path.should == path
        group.sitemap.location.sitemaps_path.to_s.should == path
      end
    end

    describe "default_host" do
      it "should inherit the default_host" do
        @ls.group.default_host.should == @default_host
      end

      it "should set the default_host" do
        host = 'http://defaulthost.com'
        group = @ls.group(:default_host => host)
        group.default_host.should == host
        group.sitemap.location.host.should == host
      end
    end

    describe "sitemaps_host" do
      it "should set the sitemaps host" do
        @host = 'http://sitemaphost.com'
        @group = @ls.group(:sitemaps_host => @host)
        @group.sitemaps_host.should == @host
        @group.sitemap.location.host.should == @host
      end

      it "should finalize the sitemap if it is the only option" do
        @ls.expects(:finalize_sitemap!)
        @ls.group(:sitemaps_host => 'http://test.com') {}
      end

      it "should use the same sitemaps_namer" do
        @group = @ls.group(:sitemaps_host => 'http://test.com') {}
        @group.sitemap.location.namer.should == @ls.sitemap.location.namer
      end
    end

    describe "sitemaps_namer" do
      it "should inherit the value" do
        @ls.group.sitemaps_namer.should == @ls.sitemaps_namer
        @ls.group.sitemap.location.namer.should == @ls.sitemaps_namer
      end

      it "should set the value" do
        namer = SitemapGenerator::SitemapNamer.new(:xxx)
        group = @ls.group(:sitemaps_namer => namer)
        group.sitemaps_namer.should == namer
        group.sitemap.location.namer.should == namer
        group.sitemap.location.filename.should =~ /xxx/
      end
    end

    describe "should share the current sitemap" do
      it "if only default_host is passed" do
        group = @ls.group(:default_host => 'http://newhost.com')
        group.sitemap.should == @ls.sitemap
        group.sitemap.location.host.should == 'http://newhost.com'
      end
    end

    describe "should not share the current sitemap" do
      {
        :filename => :xxx,
        :sitemaps_path => 'en/',
        :filename => :example,
        :sitemaps_namer => SitemapGenerator::SitemapNamer.new(:sitemap)
      }.each do |key, value|
        it "if #{key} is present" do
          @ls.group(key => value).sitemap.should_not == @ls.sitemap
        end
      end
    end

    describe "finalizing" do
      it "should finalize the sitemaps if a block is passed" do
        @group = @ls.group
        @group.sitemap.finalized?.should be_false
      end

      it "should only finalize the sitemaps if a block is passed" do
        @group = @ls.group
        @group.sitemap.finalized?.should be_false
      end

      it "should not finalize the sitemap if a group is created" do
        @ls.create { group {} }
        @ls.sitemap.empty?.should be_true
        @ls.sitemap.finalized?.should be_false
      end

      {:sitemaps_path => 'en/',
        :filename => :example,
        :sitemaps_namer => SitemapGenerator::SitemapNamer.new(:sitemap)}.each do |k, v|

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

  describe "options to create" do
    before :each do
      @ls = SitemapGenerator::LinkSet.new(:default_host => @default_host)
      @ls.expects(:finalize!)
    end

    it "should set include_index" do
      original = @ls.include_index
      @ls.create(:include_index => !original).include_index.should_not == original
    end

    it "should set include_root" do
      original = @ls.include_root
      @ls.create(:include_root => !original).include_root.should_not == original
    end

    it "should set the filename" do
      ls = @ls.create(:filename => :xxx)
      ls.filename.should == :xxx
      ls.sitemap.location.filename.should =~ /xxx/
    end

    it "should set verbose" do
      original = @ls.verbose
      @ls.create(:verbose => !original).verbose.should_not == original
    end

    it "should set the sitemaps_path" do
      path = 'new/path'
      ls = @ls.create(:sitemaps_path => path)
      ls.sitemaps_path.should == path
      ls.sitemap.location.sitemaps_path.to_s.should == path
    end

    it "should set the default_host" do
      host = 'http://defaulthost.com'
      ls = @ls.create(:default_host => host)
      ls.default_host.should == host
      ls.sitemap.location.host.should == host
    end

    it "should set the sitemaps host" do
      @host = 'http://sitemaphost.com'
      ls = @ls.create(:sitemaps_host => @host)
      ls.sitemaps_host.should == @host
      ls.sitemap.location.host.should == @host
    end

    it "should set the sitemaps_namer" do
      namer = SitemapGenerator::SitemapNamer.new(:xxx)
      ls = @ls.create(:sitemaps_namer => namer)
      ls.sitemaps_namer.should == namer
      ls.sitemap.location.namer.should == namer
      ls.sitemap.location.filename.should =~ /xxx/
    end

    it "should support both sitemaps_namer and filename options" do
      namer = SitemapGenerator::SitemapNamer.new("sitemap1_")
      ls = @ls.create(:sitemaps_namer => namer, :filename => "sitemap1")
      ls.sitemaps_namer.should == namer
      ls.sitemap.location.namer.should == namer
      ls.sitemap.location.filename.should =~ /sitemap1_1/
      ls.sitemap_index.location.filename.should =~ /sitemap1_index/
    end

    it "should support both sitemaps_namer and filename options no matter the order" do
      namer = SitemapGenerator::SitemapNamer.new("sitemap1_")
      options = ActiveSupport::OrderedHash.new
      options[:sitemaps_namer] = namer
      options[:filename] = "sitemap1"
      ls = @ls.create(options)
      ls.sitemap.location.filename.should =~ /sitemap1_1/
      ls.sitemap_index.location.filename.should =~ /sitemap1_index/
    end
  end

  describe "reset!" do
    it "should reset the sitemap namer" do
      SitemapGenerator::Sitemap.sitemaps_namer.expects(:reset)
      SitemapGenerator::Sitemap.create(:default_host => 'http://cnn.com')
    end

    it "should reset the default link variable" do
      SitemapGenerator::Sitemap.instance_variable_set(:@added_default_links, true)
      SitemapGenerator::Sitemap.create(:default_host => 'http://cnn.com')
      SitemapGenerator::Sitemap.instance_variable_set(:@added_default_links, false)
    end
  end

  describe "include_root?" do
    it "should return false" do
      @ls.include_root = false
      @ls.include_root.should be_false
    end

    it "should return true" do
      @ls.include_root = true
      @ls.include_root.should be_true
    end
  end

  describe "include_index?" do
    let(:sitemaps_host)  { 'http://amazon.com' }

    before :each do
      @ls.default_host = @default_host
    end

    it "should be true if no sitemaps_host set, or it is the same" do
      @ls.include_index = true
      @ls.sitemaps_host = @default_host
      @ls.include_index?.should be_true

      @ls.sitemaps_host = nil
      @ls.include_index?.should be_true
    end

    it "should be false if include_index is false or sitemaps_host differs" do
      @ls.include_index = false
      @ls.sitemaps_host = @default_host
      @ls.include_index?.should be_false

      @ls.include_index = true
      @ls.sitemaps_host = sitemaps_host
      @ls.include_index?.should be_false
    end

    it "should return false" do
      ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :sitemaps_host => sitemaps_host)
      ls.include_index?.should be_false
    end

    it "should return true" do
      ls = SitemapGenerator::LinkSet.new(:default_host => @default_host, :sitemaps_host => @default_host)
      ls.include_index?.should be_true
    end
  end
end
