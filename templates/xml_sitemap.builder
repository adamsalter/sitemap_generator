xml.instruct!
xml.urlset "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", 
  "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd", 
  "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  links.each do |link|
    xml.url do
      xml.loc        link[:loc]
      xml.lastmod    w3c_date(link[:lastmod]) if link[:lastmod]
      xml.changefreq link[:changefreq]        if link[:changefreq]
      xml.priority   link[:priority]          if link[:priority]
    end 
  end

end
