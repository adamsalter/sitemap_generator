xml.instruct!
xml.urlset "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

    links.each_with_index do |link,index|
      puts "#{index}/#{links.size}"
      buffer_url = ""
      url = Builder::XmlMarkup.new(:target=>buffer_url)
      url.url do
        url.loc        link[:loc]
        url.lastmod    w3c_date(link[:lastmod])   if link[:lastmod]
        url.changefreq link[:changefreq]          if link[:changefreq]
        url.priority   link[:priority]            if link[:priority]

        unless link[:images].blank?
          link[:images].each do |image|
            url.image:image do
              url.image :loc, image[:loc]
              url.image :caption, image[:caption]             if image[:caption]
              url.image :geo_location, image[:geo_location]   if image[:geo_location]
              url.image :title, image[:title]                 if image[:title]
              url.image :license, image[:license]             if image[:license]
            end
          end
        end
      end

      if (buffer+buffer_url).size < 10.megabytes
        xml << buffer_url
      else
        slice_index = index
        break
      end
    end
end

