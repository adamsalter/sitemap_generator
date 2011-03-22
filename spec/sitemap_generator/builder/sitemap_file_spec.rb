require 'spec_helper'

context 'SitemapGenerator::Builder::SitemapFile' do
  before :each do
    @s = SitemapGenerator::Builder::SitemapFile.new(:directory => 'public/test/', :host => 'http://example.com/test/')
  end

  it "should return the name of the sitemap file" do
    @s.filename.should == 'sitemap1.xml.gz'
  end

  it "should return the URL" do
    @s.url.should == 'http://example.com/test/sitemap1.xml.gz'
  end

  it "should return the path" do
    @s.path.should == 'public/test/sitemap1.xml.gz'
  end

  it "should be empty" do
    @s.empty?.should be_true
    @s.link_count.should == 0
  end

  it "should not have a last modification data" do
    @s.lastmod.should be_nil
  end

  it "should not be finalized" do
    @s.finalized?.should be_false
  end

  context "next" do
    before :each do
      @s = @s.next
    end

    it "should have the next filename in the sequence" do
      @s.filename.should == 'sitemap2.xml.gz'
    end

    it "should inherit the same options" do
      @s.url.should == 'http://example.com/test/sitemap2.xml.gz'
      @s.path.should == 'public/test/sitemap2.xml.gz'
    end
  end
end
