
# Set the host name for URL creation
SitemapPlugin::Sitemap.default_host = "http://www.example.com"

# Put links creation logic here (the root path '/' and sitemap files are added automatically)
# Usage:
# sitemap.add path, options = { :priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => default_host }
# default options are used if you don't specify
SitemapPlugin::Sitemap.add_links do |sitemap|
  # add '/articles'
  sitemap.add articles_path # :priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => default_host

  # add all individual articles
  Article.find(:all).each do |a|
    sitemap.add article_path(a), :lastmod => a.updated_at
  end
  
  # add merchant path
  sitemap.add '/purchase', :host => "https://www.example.com"
end