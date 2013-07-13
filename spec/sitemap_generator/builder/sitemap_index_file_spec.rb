require 'spec_helper'

describe 'SitemapGenerator::Builder::SitemapIndexFile' do
  let(:location) { SitemapGenerator::SitemapLocation.new(:filename => 'sitemap.xml.gz', :public_path => '/public/', :host => 'http://example.com/') }
  let(:index)    { SitemapGenerator::Builder::SitemapIndexFile.new(location) }

  before :each do
    index.location[:sitemaps_path] = 'test/'
  end

  it "should return the URL" do
    index.location.url.should == 'http://example.com/test/sitemap.xml.gz'
  end

  it "should return the path" do
    index.location.path.should == '/public/test/sitemap.xml.gz'
  end

  it "should be empty" do
    index.empty?.should be_true
    index.link_count.should == 0
  end

  it "should not have a last modification data" do
    index.lastmod.should be_nil
  end

  it "should not be finalized" do
    index.finalized?.should be_false
  end

  it "filename should be set" do
    index.location.filename.should == 'sitemap.xml.gz'
  end

  it "should have a default namer" do
    index = SitemapGenerator::Builder::SitemapIndexFile.new
    index.location.filename.should == 'sitemap.xml.gz'
  end

  describe "link_count" do
    it "should return the link count" do
      index.instance_variable_set(:@link_count, 10)
      index.link_count.should == 10
    end
  end

  describe "create_index?" do
    it "should return false" do
      index.location[:create_index] = false
      index.create_index?.should be_false

      index.instance_variable_set(:@link_count, 10)
      index.create_index?.should be_false
    end

    it "should return true" do
      index.location[:create_index] = true
      index.create_index?.should be_true

      index.instance_variable_set(:@link_count, 1)
      index.create_index?.should be_true
    end

    it "when :auto, should be true if more than one link" do
      index.instance_variable_set(:@link_count, 1)
      index.location[:create_index] = :auto
      index.create_index?.should be_false

      index.instance_variable_set(:@link_count, 2)
      index.create_index?.should be_true
    end
  end

  describe "add" do
    it "should use the host provided" do
      url = SitemapGenerator::Builder::SitemapIndexUrl.new('/one', :host => 'http://newhost.com/')
      SitemapGenerator::Builder::SitemapIndexUrl.expects(:new).with('/one', :host => 'http://newhost.com').returns(url)
      index.add '/one', :host => 'http://newhost.com'
    end

    it "should use the host from the location" do
      url = SitemapGenerator::Builder::SitemapIndexUrl.new('/one', :host => 'http://example.com/')
      SitemapGenerator::Builder::SitemapIndexUrl.expects(:new).with('/one', :host => 'http://example.com/').returns(url)
      index.add '/one'
    end

    describe "when adding manually" do
      it "should reserve a name" do
        index.expects(:reserve_name)
        index.add '/link'
      end

      it "should create index" do
        index.create_index?.should be_false
        index.add '/one'
        index.create_index?.should be_true
      end
    end
  end

  describe "index_url" do
    it "when not creating an index, should be the first sitemap url" do
      index.instance_variable_set(:@create_index, false)
      index.instance_variable_set(:@first_sitemap_url, 'http://test.com/index.xml')
      index.create_index?.should be_false
      index.index_url.should == 'http://test.com/index.xml'
    end

    it "if there's no first sitemap url, should default to the index location url" do
      index.instance_variable_set(:@create_index, false)
      index.instance_variable_set(:@first_sitemap_url, nil)
      index.create_index?.should be_false
      index.index_url.should == index.location.url
      index.index_url.should == 'http://example.com/test/sitemap.xml.gz'
    end

    it "when creating an index, should be the index location url" do
      index.instance_variable_set(:@create_index, true)
      index.index_url.should == index.location.url
      index.index_url.should == 'http://example.com/test/sitemap.xml.gz'
    end
  end
end
