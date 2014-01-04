require 'spec_helper'

describe SitemapGenerator::SimpleNamer do
  it "should generate file names" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap)
    namer.to_s.should == "sitemap.xml.gz"
    namer.next.to_s.should == "sitemap1.xml.gz"
    namer.next.to_s.should == "sitemap2.xml.gz"
  end

  it "should set the file extension" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap, :extension => '.xyz')
    namer.to_s.should == "sitemap.xyz"
    namer.next.to_s.should == "sitemap1.xyz"
    namer.next.to_s.should == "sitemap2.xyz"
  end

  it "should set the starting index" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap, :start => 10)
    namer.to_s.should == "sitemap.xml.gz"
    namer.next.to_s.should == "sitemap10.xml.gz"
    namer.next.to_s.should == "sitemap11.xml.gz"
  end

  it "should accept a string name" do
    namer = SitemapGenerator::SimpleNamer.new('abc-def')
    namer.to_s.should == "abc-def.xml.gz"
    namer.next.to_s.should == "abc-def1.xml.gz"
    namer.next.to_s.should == "abc-def2.xml.gz"
  end

  it "should return previous name" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap)
    namer.to_s.should == "sitemap.xml.gz"
    namer.next.to_s.should == "sitemap1.xml.gz"
    namer.previous.to_s.should == "sitemap.xml.gz"
    namer.next.next.to_s.should == "sitemap2.xml.gz"
    namer.previous.to_s.should == "sitemap1.xml.gz"
    namer.next.next.to_s.should == "sitemap3.xml.gz"
    namer.previous.to_s.should == "sitemap2.xml.gz"
  end

  it "should raise if already at the start" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap)
    namer.to_s.should == "sitemap.xml.gz"
    lambda { namer.previous }.should raise_error
  end

  it "should handle names with underscores" do
    namer = SitemapGenerator::SimpleNamer.new("sitemap1_")
    namer.to_s.should == "sitemap1_.xml.gz"
    namer.next.to_s.should == "sitemap1_1.xml.gz"
  end

  it "should reset the namer" do
    namer = SitemapGenerator::SimpleNamer.new(:sitemap)
    namer.to_s.should == "sitemap.xml.gz"
    namer.next.to_s.should == "sitemap1.xml.gz"
    namer.reset
    namer.to_s.should == "sitemap.xml.gz"
    namer.next.to_s.should == "sitemap1.xml.gz"
  end

  describe "should handle the zero option" do
    it "as a string" do
      namer = SitemapGenerator::SimpleNamer.new(:sitemap, :zero => "string")
      namer.to_s.should == "sitemapstring.xml.gz"
      namer.next.to_s.should == "sitemap1.xml.gz"
    end

    it "as an integer" do
      namer = SitemapGenerator::SimpleNamer.new(:sitemap, :zero => 0)
      namer.to_s.should == "sitemap0.xml.gz"
      namer.next.to_s.should == "sitemap1.xml.gz"
    end

    it "as a string" do
      namer = SitemapGenerator::SimpleNamer.new(:sitemap, :zero => "_index")
      namer.to_s.should == "sitemap_index.xml.gz"
      namer.next.to_s.should == "sitemap1.xml.gz"
    end

    it "as a symbol" do
      namer = SitemapGenerator::SimpleNamer.new(:sitemap, :zero => :index)
      namer.to_s.should == "sitemapindex.xml.gz"
      namer.next.to_s.should == "sitemap1.xml.gz"
    end

    it "with a starting index" do
      namer = SitemapGenerator::SimpleNamer.new(:sitemap, :zero => 'abc', :start => 10)
      namer.to_s.should == "sitemapabc.xml.gz"
      namer.next.to_s.should == "sitemap10.xml.gz"
      namer.next.to_s.should == "sitemap11.xml.gz"
    end
  end
end
