xml.instruct!
xml.urlset "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

    links.each do |link|
      xml.url do
        xml.loc        link[:loc]
        xml.lastmod    w3c_date(link[:lastmod]) if link[:lastmod]
        xml.changefreq link[:changefreq]        if link[:changefreq]
        xml.priority   link[:priority]          if link[:priority]

        unless link[:images].blank?
          link[:images].each do |image|
            xml.image:image do
              xml.image :loc, image[:loc]                     if image[:loc]
              xml.image :caption, image[:caption]             if image[:caption]
              xml.image :geo_location, image[:geo_location]   if image[:geo_location]
              xml.image :title, image[:title]                 if image[:title]
              xml.image :license, image[:license]             if image[:license]
            end
          end
        end

      end
    end

end

