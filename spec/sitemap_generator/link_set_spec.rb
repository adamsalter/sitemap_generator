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
end