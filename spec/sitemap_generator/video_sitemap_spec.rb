require 'spec_helper'

describe "SitemapGenerator" do

  it "should add the video sitemap element" do
    loc = 'http://www.example.com/cool_video.html'
    thumbnail_loc = 'http://www.example.com/video1_thumbnail.png'
    title = 'Cool Video'
    content_loc = 'http://www.example.com/cool_video.mpg'
    player_loc = 'http://www.example.com/cool_video_player.swf'
    gallery_loc = 'http://www.example.com/cool_video_gallery'
    allow_embed = true
    autoplay = 'id=123'
    description = 'An new perspective in cool video technology'
    tags = %w{tag1 tag2 tag3}
    category = 'cat1'
    uploader = 'sokrates'
    uploader_info = 'http://sokrates.example.com'

    video_xml_fragment = SitemapGenerator::Builder::SitemapUrl.new('cool_video.html', {
      :host => 'http://www.example.com',
      :video => {
        :thumbnail_loc => thumbnail_loc,
        :title => title,
        :content_loc => content_loc,
        :gallery_loc => gallery_loc,
        :player_loc => player_loc,
        :description => description,
        :allow_embed => allow_embed,
        :autoplay => autoplay,
        :tags => tags,
        :category => category,
        :uploader => uploader,
        :uploader_info => uploader_info
      }
    }).to_xml

    # Check that the options were parsed correctly
    doc = Nokogiri::XML.parse("<root xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'>#{video_xml_fragment}</root>")
    url = doc.at_xpath("//url")
    url.should_not be_nil
    url.at_xpath("loc").text.should == loc

    video = url.at_xpath("video:video")
    video.should_not be_nil
    video.at_xpath("video:thumbnail_loc").text.should == thumbnail_loc
    video.at_xpath("video:gallery_loc").text.should == gallery_loc
    video.at_xpath("video:title").text.should == title
    video.at_xpath("video:content_loc").text.should == content_loc
    video.xpath("video:tag").size.should == 3
    video.xpath("video:category").size.should == 1

    # Google's documentation and published schema don't match some valid elements may
    # not validate.
    xml_fragment_should_validate_against_schema(video, 'http://www.google.com/schemas/sitemap-video/1.1', 'sitemap-video')

    player_loc_node = video.at_xpath("video:player_loc")
    player_loc_node.should_not be_nil
    player_loc_node.text.should == player_loc
    player_loc_node.attribute('allow_embed').text.should == (allow_embed ? 'yes' : 'no')
    player_loc_node.attribute('autoplay').text.should == autoplay

    video.xpath("video:uploader").text.should == uploader
    video.xpath("video:uploader").attribute("info").text.should == uploader_info
  end

  it "should support multiple videos" do
    loc = 'http://www.example.com/cool_video.html'
    thumbnail_loc = 'http://www.example.com/video1_thumbnail.png'
    title = 'Cool Video'
    content_loc = 'http://www.example.com/cool_video.mpg'
    player_loc = 'http://www.example.com/cool_video_player.swf'
    gallery_loc = 'http://www.example.com/cool_video_gallery'
    allow_embed = true
    autoplay = 'id=123'
    description = 'An new perspective in cool video technology'
    tags = %w{tag1 tag2 tag3}
    category = 'cat1'
    uploader = 'sokrates'
    uploader_info = 'http://sokrates.example.com'

    video_xml_fragment = SitemapGenerator::Builder::SitemapUrl.new('cool_video.html', {
      :host => 'http://www.example.com',
      :videos => [{
        :thumbnail_loc => thumbnail_loc,
        :title => title,
        :content_loc => content_loc,
        :gallery_loc => gallery_loc,
        :player_loc => player_loc,
        :description => description,
        :allow_embed => allow_embed,
        :autoplay => autoplay,
        :tags => tags,
        :category => category,
        :uploader => uploader,
        :uploader_info => uploader_info
      },
      {
        :thumbnail_loc => thumbnail_loc,
        :title => title,
        :content_loc => content_loc,
        :gallery_loc => gallery_loc,
        :player_loc => player_loc,
        :description => description,
        :allow_embed => allow_embed,
        :autoplay => autoplay,
        :tags => tags,
        :category => category,
        :uploader => uploader,
        :uploader_info => uploader_info
      }]
    }).to_xml

    # Check that the options were parsed correctly
    doc = Nokogiri::XML.parse("<root xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'>#{video_xml_fragment}</root>")
    url = doc.at_xpath("//url")
    url.should_not be_nil
    url.at_xpath("loc").text.should == loc

    doc.xpath('//video:video').count.should == 2
    doc.xpath('//video:video').each do |video|
      xml_fragment_should_validate_against_schema(video, 'http://www.google.com/schemas/sitemap-video/1.1', 'sitemap-video')
    end
  end
end
