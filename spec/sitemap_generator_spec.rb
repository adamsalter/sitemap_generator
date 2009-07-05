require File.dirname(__FILE__) + '/spec_helper'

describe "SitemapGenerator Rake Task" do
  it "should fail if hostname not defined" do
    
  end
end

describe "SitemapGenerator library" do
  it "should be empty on startup" do
    SitemapGenerator::Sitemap.links.should == []
  end
end