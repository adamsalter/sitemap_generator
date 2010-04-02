SitemapGenerator::Sitemap.default_host = "http://www.example.com"
SitemapGenerator::Sitemap.yahoo_app_id = false

SitemapGenerator::Sitemap.add_links do |sitemap|
  sitemap.add contents_path, :priority => 0.7, :changefreq => 'daily'

  # add all individual articles
  Content.find(:all).each do |c|
    sitemap.add content_path(c), :lastmod => c.updated_at
  end

  sitemap.add "/merchant_path", :host => "https://www.example.com"
end
