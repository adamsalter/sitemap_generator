require 'spec_helper'

describe SitemapGenerator::LinkSet do

  context "initializer options" do
    options = [:public_path, :sitemaps_path, :default_host, :filename]
    values = [File.expand_path(Rails.root + 'tmp/'), 'mobile/', 'http://myhost.com', :xxx]

    options.zip(values).each do |option, value|
      it "should set #{option} to #{value}" do
        @ls = SitemapGenerator::LinkSet.new(option => value)
        @ls.send(option).should == value
      end
    end

    it "should support calling with positional arguments (deprecated)" do
      @ls = SitemapGenerator::LinkSet.new(*values[0..3])
      options.zip(values).each do |option, value|
        @ls.send(option).should == value
      end
    end
  end

  context "default options" do
    default_options = {
      :filename => :sitemap,
      :sitemaps_path => nil,
      :public_path => File.expand_path(Rails.root + 'public/'),
      :default_host => nil,
      :include_index => true,
      :include_root => true
    }

    before :all do
      @ls = SitemapGenerator::LinkSet.new
    end

    default_options.each do |option, value|
      it "#{option} should default to #{value}" do
        @ls.send(option).should == value
      end
    end
  end

  context "include_root include_index option" do
    it "should not include the root url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => 'http://www.example.com', :include_root => false)
      @ls.include_root.should be_false
      @ls.include_index.should be_true
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 1
    end

    it "should not include the sitemap index url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => 'http://www.example.com', :include_index => false)
      @ls.include_root.should be_true
      @ls.include_index.should be_false
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 1
    end

    it "should not include the root url or the sitemap index url" do
      @ls = SitemapGenerator::LinkSet.new(:default_host => 'http://www.example.com', :include_root => false, :include_index => false)
      @ls.include_root.should be_false
      @ls.include_index.should be_false
      @ls.add_links { |sitemap| }
      @ls.sitemap.link_count.should == 0
    end
  end

  context "sitemaps_directory" do
    before do
      @ls = SitemapGenerator::LinkSet.new
    end

    it "should default to public/" do
      @ls.sitemaps_directory.should == File.expand_path(Rails.root + 'public/')
    end

    it "should change when the public_path is changed" do
      @ls.public_path = 'tmp/'
      @ls.sitemaps_directory.should == File.expand_path(Rails.root + 'tmp/')
    end

    it "should change when the sitemaps_path is changed" do
      @ls.sitemaps_path = 'sitemaps/'
      @ls.sitemaps_directory.should == File.expand_path(Rails.root + 'public/sitemaps/')
    end
  end

  context "sitemaps_url" do
    before do
      @ls = SitemapGenerator::LinkSet.new
    end

    it "should raise if no default host is set" do
      lambda { @ls.sitemaps_url }.should raise SitemapGenerator::SitemapError
    end
    
    it "should change when the default_host is changed" do
      @ls.default_host = 'http://one.com'
      @ls.sitemaps_url.should == 'http://one.com'
    end

    it "should change when the sitemaps_path is changed" do
      @ls.default_host = 'http://one.com'
      @ls.sitemaps_path = 'sitemaps/'
      @ls.sitemaps_url.should == 'http://one.com/sitemaps/'
    end
  end
end