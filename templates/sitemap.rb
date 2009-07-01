
# Set the host name for URL creation
SitemapPlugin::Sitemap.default_host = "http://www.example.com"

# Put links creation logic here
# (the root path '/' and sitemap files are added automatically)
SitemapPlugin::Sitemap.add_links do |sitemap|
  # add '/articles'
  # default values are added if you don't specify anything
  sitemap.add articles_path # :priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => default_host

  # add all articles
  Article.find(:all).each do |a|
    sitemap.add article_path(a), :lastmod => a.updated_at
  end
  
  # add merchant path
  sitemap.add '/purchase', :host => "https://www.example.com"
end