require "spec_helper"

def with_max_links(num)
  original = SitemapGenerator::MAX_SITEMAP_LINKS
  SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, num)
  yield
  SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, original)
end

describe "Sitemap Groups" do
  before :each do
    @sm = ::SitemapGenerator::LinkSet.new(:default_host => 'http://test.com')
    FileUtils.rm_rf(SitemapGenerator.app.root + 'public/')
  end

  it "should not finalize the default sitemap if using groups" do
    @sm.create do
      group(:filename => :sitemap_en) do
        add '/en'
      end
    end

    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_en1.xml.gz')
    file_should_not_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
  end

  it "should add default links if no groups are created" do
    @sm.create do
    end
    @sm.link_count.should == 2
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
  end

  it "should add links to the default sitemap" do
    @sm.create do
      add '/before'
      group(:filename => :sitemap_en) { }
      add '/after'
    end
    @sm.link_count.should == 4
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_en1.xml.gz')
  end

  it "should rollover when sitemaps are full" do
    with_max_links(1) {
      @sm.include_index = false
      @sm.include_root = false
      @sm.create do
        add '/before'
        group(:filename => :sitemap_en, :sitemaps_path => 'en/') do
          add '/one'
          add '/two'
        end
        add '/after'
      end
    }
    @sm.link_count.should == 4
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap2.xml.gz')
    file_should_not_exist(SitemapGenerator.app.root + 'public/sitemap3.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/en/sitemap_en1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/en/sitemap_en2.xml.gz')
    file_should_not_exist(SitemapGenerator.app.root + 'public/en/sitemap_en3.xml.gz')
  end
end
