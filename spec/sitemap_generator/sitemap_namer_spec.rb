require 'spec_helper'

describe 'SitemapGenerator::SitemapNamer' do

  it "should generate file names" do
    namer = SitemapGenerator::SitemapNamer.new(:sitemap)
    namer.next.should == "sitemap1.xml.gz"
    namer.next.should == "sitemap2.xml.gz"
    namer.next.should == "sitemap3.xml.gz"
  end
  
  it "should set the file extension" do
    namer = SitemapGenerator::SitemapNamer.new(:sitemap, :extension => '.xyz')
    namer.next.should == "sitemap1.xyz"
    namer.next.should == "sitemap2.xyz"
    namer.next.should == "sitemap3.xyz"
  end

  it "should set the starting index" do
    namer = SitemapGenerator::SitemapNamer.new(:sitemap, :start => 10)
    namer.next.should == "sitemap10.xml.gz"
    namer.next.should == "sitemap11.xml.gz"
    namer.next.should == "sitemap12.xml.gz"
  end
  
  it "should accept a string name" do
    namer = SitemapGenerator::SitemapNamer.new('abc-def')
    namer.next.should == "abc-def1.xml.gz"
    namer.next.should == "abc-def2.xml.gz"
    namer.next.should == "abc-def3.xml.gz"
  end
  
  it "should return previous name" do
    namer = SitemapGenerator::SitemapNamer.new(:sitemap)
    namer.next.should == "sitemap1.xml.gz"
    namer.next.should == "sitemap2.xml.gz"
    namer.previous.should == "sitemap1.xml.gz"
    namer.next.should == "sitemap2.xml.gz"
  end
  
  it "should raise if already at the start" do
    namer = SitemapGenerator::SitemapNamer.new(:sitemap)
    namer.next.should == "sitemap1.xml.gz"
    lambda { namer.previous }.should raise_error
  end
end