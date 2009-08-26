
# <?xml version="1.0" encoding="UTF-8"?>
# <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
#    <sitemap>
#       <loc>http://www.example.com/sitemap1.xml.gz</loc>
#       <lastmod>2004-10-01T18:23:17+00:00</lastmod>
#    </sitemap>
#    <sitemap>
#       <loc>http://www.example.com/sitemap2.xml.gz</loc>
#       <lastmod>2005-01-01</lastmod>
#    </sitemap>
# </sitemapindex>

xml.instruct!
xml.sitemapindex "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap_files.each do |file|
    xml.sitemap do
      xml.loc url_with_hostname(File.basename(file))
      xml.lastmod w3c_date(File.mtime(file))
    end
  end
end