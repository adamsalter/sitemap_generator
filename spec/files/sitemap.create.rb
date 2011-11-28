SitemapGenerator::Sitemap.default_host = "http://www.example.com"

SitemapGenerator::Sitemap.create do
  add '/contents', :priority => 0.7, :changefreq => 'daily'

  # add all individual articles
  Content.find(:all).each do |c|
    add "/content/#{c.to_param}", :lastmod => c.updated_at
  end

  add "/merchant_path", :host => "https://www.example.com"
end
