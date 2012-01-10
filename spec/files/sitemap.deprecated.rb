SitemapGenerator::Sitemap.default_host = "http://www.example.com"
SitemapGenerator::Sitemap.yahoo_app_id = false

SitemapGenerator::Sitemap.add_links do |sitemap|
  sitemap.add '/contents', :priority => 0.7, :changefreq => 'daily'

  # add all individual articles
  (1..10).each do |i|
    sitemap.add "/content/#{i}"
  end

  sitemap.add "/merchant_path", :host => "https://www.example.com"
end
