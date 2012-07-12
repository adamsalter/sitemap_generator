require "spec_helper"

def with_max_links(num)
  SitemapGenerator::Utilities.with_warnings(nil) do
    original = SitemapGenerator::MAX_SITEMAP_LINKS
    SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, num)
    yield
    SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, original)
  end
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
    @sm.link_count.should == 1
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
  end

  it "should add links to the default sitemap" do
    @sm.create do
      add '/before'
      group(:filename => :sitemap_en) { }
      add '/after'
    end
    @sm.link_count.should == 3
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

  it "should support multiple groups" do
    @sm.create do
      group(:filename => :sitemap_en, :sitemaps_path => 'en/') do
        add '/one'
      end
      group(:filename => :sitemap_fr, :sitemaps_path => 'fr/') do
        add '/one'
      end
    end
    @sm.link_count.should == 2
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/en/sitemap_en1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/fr/sitemap_fr1.xml.gz')
  end

  it "the sitemap shouldn't be finalized if the groups don't conflict" do
    @sm.create do
      add 'one'
      group(:filename => :first) { add '/two' }
      add 'three'
      group(:filename => :second) { add '/four' }
      add 'five'
    end
    @sm.link_count.should == 6
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/first1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/second1.xml.gz')
  end

  it "groups should share the sitemap if the sitemap location is unchanged" do
    @sm.create do
      add 'one'
      group(:default_host => 'http://newhost.com') { add '/two' }
      add 'three'
      group(:default_host => 'http://betterhost.com') { add '/four' }
      add 'five'
    end
    @sm.link_count.should == 6
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    file_should_not_exist(SitemapGenerator.app.root + 'public/sitemap2.xml.gz')
  end

  it "sitemaps should be finalized if virtual location settings are changed" do
    @sm.create do
      add 'one'
      group(:sitemaps_path => :en) { add '/two' }
      add 'three'
      group(:sitemaps_host => 'http://newhost.com') { add '/four' }
      add 'five'
    end
    @sm.link_count.should == 6
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap2.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/sitemap3.xml.gz')
    file_should_not_exist(SitemapGenerator.app.root + 'public/sitemap4.xml.gz')
    file_should_exist(SitemapGenerator.app.root + 'public/en/sitemap1.xml.gz')
  end
end
