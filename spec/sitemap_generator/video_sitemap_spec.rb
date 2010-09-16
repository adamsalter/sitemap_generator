require 'spec_helper'

describe "SitemapGenerator" do

  it "should add the video sitemap element" do
    loc = 'http://www.example.com/cool_video.html'
    thumbnail_loc = 'http://www.example.com/video1_thumbnail.png'
    title = 'Cool Video'
    content_loc = 'http://www.example.com/cool_video.mpg'
    player_loc = 'http://www.example.com/cool_video_player.swf'
    allow_embed = true
    autoplay = 'id=123'
    description = 'An new perspective in cool video technology'
    tags = %w{tag1 tag2 tag3}
    category = 'cat1'
    
    sitemap_generator = SitemapGenerator::Builder::SitemapFile.new(File.join(::Rails.root, '/public/'), 'sitemap.xml.gz', 'http://example.com')
    video_link = {
      :loc => loc,
      :video => {
        :thumbnail_loc => thumbnail_loc,
        :title => title,
        :content_loc => content_loc,
        :player_loc => player_loc,
        :description => description,
        :allow_embed => allow_embed,
        :autoplay => autoplay,
        :tags => tags,
        :category => category
      }
    }

    # generate the video sitemap xml fragment
    video_xml_fragment = sitemap_generator.build_xml(::Builder::XmlMarkup.new, video_link)

    # validate the xml generated
    #video_xml_fragment.should_not be_nil
    doc = Nokogiri::XML.parse("<root xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'>#{video_xml_fragment}</root>")
    
    
    # Check that the options were parsed correctly
    url = doc.at_xpath("//url")
    url.should_not be_nil
    url.at_xpath("loc").text.should == loc

    video = url.at_xpath("video:video")
    video.should_not be_nil
    video.at_xpath("video:thumbnail_loc").text.should == thumbnail_loc
    video.at_xpath("video:title").text.should == title
    video.at_xpath("video:content_loc").text.should == content_loc
    video.xpath("video:tag").size.should == 3
    video.xpath("video:category").size.should == 1

    xml_fragment_should_validate_against_schema(video, 'http://www.google.com/schemas/sitemap-video/1.1', 'sitemap-video')
    
    player_loc_node = video.at_xpath("video:player_loc")
    player_loc_node.should_not be_nil
    player_loc_node.text.should == player_loc
    player_loc_node.attribute('allow_embed').text.should == (allow_embed ? 'yes' : 'no')
    player_loc_node.attribute('autoplay').text.should == autoplay
  end
end
