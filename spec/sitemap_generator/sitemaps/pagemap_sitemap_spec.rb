require 'spec_helper'

describe "SitemapGenerator" do
  let(:schema) { SitemapGenerator::SCHEMAS['pagemap'] }
  
  it "should add the pagemap sitemap element" do
    pagemap_xml_fragment = SitemapGenerator::Builder::SitemapUrl.new('my_page.html', {
      :host => 'http://www.example.com',

      :pagemap => {
        :dataobjects => [
          {
            :type => 'document',
            :id => 'hibachi',
            :attributes => [
              {:name => 'name', :value => 'Dragon'},
              {:name => 'review', :value => 3.5},
            ]
          },
          {
            :type => 'stats',
            :attributes => [
              {:name => 'installs', :value => 2000},
              {:name => 'comments', :value => 200},
            ]
          }
        ]
      }
    }).to_xml

    # Nokogiri is a fickle beast.  We have to add the namespace and define
    # the prefix in order for XPath queries to work.  And then we have to
    # reingest because otherwise Nokogiri doesn't use it.
    doc = Nokogiri::XML.parse(pagemap_xml_fragment)
    doc.root.add_namespace_definition('pagemap', schema)
    doc = Nokogiri::XML.parse(doc.to_xml)
    
    url = doc.at_xpath("//url")
    loc = url.at_xpath("loc")
    loc.text.should == 'http://www.example.com/my_page.html'
    
    pagemap =  doc.at_xpath('//pagemap:PageMap', 'pagemap' => schema)
    pagemap.element_children.count.should == 2
    dataobject = pagemap.at_xpath('//pagemap:DataObject')
    dataobject.attributes['type'].value.should == 'document'
    dataobject.attributes['id'].value.should == 'hibachi'
    dataobject.element_children.count.should == 2
    first_attribute = dataobject.element_children.first
    second_attribute = dataobject.element_children.last
    first_attribute.text.should == 'Dragon'
    first_attribute.attributes['name'].value.should == 'name'
    second_attribute.text.should == '3.5'
    second_attribute.attributes['name'].value.should == 'review'

    xml_fragment_should_validate_against_schema(pagemap, 'sitemap-pagemap', 'xmlns:pagemap' => schema)
  end
end
