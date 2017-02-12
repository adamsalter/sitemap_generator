require 'spec_helper'

describe "SitemapGenerator" do

  it "should add the geo sitemap element" do
    loc = 'http://www.example.com/geo_page.kml'
    format = 'kml'

    geo_xml_fragment = SitemapGenerator::Builder::SitemapUrl.new('geo_page.kml',
      :host => 'http://www.example.com',
      :geo => {
        :format => format
      }
    ).to_xml

    # Check that the options were parsed correctly
    doc = Nokogiri::XML.parse("<root xmlns:geo='#{SitemapGenerator::SCHEMAS['geo']}'>#{geo_xml_fragment}</root>")
    url = doc.at_xpath("//url")
    expect(url).not_to be_nil
    expect(url.at_xpath("loc").text).to eq(loc)

    geo = url.at_xpath("geo:geo")
    expect(geo).not_to be_nil
    expect(geo.at_xpath("geo:format").text).to eq(format)

    # Google's documentation and published schema don't match some valid elements may
    # not validate.
    xml_fragment_should_validate_against_schema(geo, 'sitemap-geo', 'xmlns:geo' => SitemapGenerator::SCHEMAS['geo'])
  end
end
