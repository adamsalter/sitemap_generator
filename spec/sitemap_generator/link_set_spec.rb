require 'spec_helper'

describe SitemapGenerator::LinkSet do
  options = {
    :filename => :xxx,
    :sitemaps_path => 'mobile/',
    :public_path => 'tmp/',
    :default_host => 'http://myhost.com'
  }

  it "should accept options as a hash" do
    linkset = SitemapGenerator::LinkSet.new(options)
    options.each do |option, value|
      linkset.send(option).should == value
    end
  end

  it "should still support calling with positional arguments" do
    args = [:public_path, :sitemaps_path, :default_host, :filename]
    args = args.map { |arg| options[arg] }
    linkset = SitemapGenerator::LinkSet.new(*args)
    options.each do |option, value|
      linkset.send(option).should == value
    end
  end

  context "default links" do
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
end