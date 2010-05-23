require 'nokogiri'

module XmlMacros
  
  def gzipped_xml_file_should_validate_against_schema(xml_gz_filename, schema_name)
    Zlib::GzipReader.open(xml_gz_filename) do |xml_file|
      xml_data_should_validate_against_schema xml_file.read, schema_name
    end
  end
  
  def xml_data_should_validate_against_schema(xml_data, schema_name)
    
    schema_file = File.join(File.dirname(__FILE__), "#{schema_name}.xsd")
    schema = Nokogiri::XML::Schema File.read(schema_file)
    
    doc = Nokogiri::XML(xml_data)
    
    schema.validate(doc).should == []
    
  end
  
  def gzipped_xml_file_should_have_minimal_whitespace(xml_gz_filename)
    Zlib::GzipReader.open(xml_gz_filename) do |xml_file|
      xml_data_should_have_minimal_whitespace xml_file.read
    end
  end
  
  def xml_data_should_have_minimal_whitespace(xml_data)
    xml_data.should_not match /^\s/
    xml_data.should_not match /\s$/
    xml_data.should_not match /\s\s+/
    xml_data.should_not match /\s[<>]/
    xml_data.should_not match /[<>]\s/
  end
  
end
