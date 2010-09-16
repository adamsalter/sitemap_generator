require 'nokogiri'

module XmlMacros

  def gzipped_xml_file_should_validate_against_schema(xml_gz_filename, schema_name)
    Zlib::GzipReader.open(xml_gz_filename) do |xml_file|
      xml_data_should_validate_against_schema(xml_file.read, schema_name)
    end
  end

  def xml_data_should_validate_against_schema(xml, schema_name)
    xml = xml.is_a?(String) ? xml : xml.to_s
    doc = Nokogiri::XML(xml)
    schema_file = File.join(File.dirname(__FILE__), 'schemas', "#{schema_name}.xsd")
    schema = Nokogiri::XML::Schema File.read(schema_file)
    schema.validate(doc).should == []
  end

  # Validate a fragment of XML against a schema.  Builds a document with a root
  # node for you so the fragment can be validated.
  #
  # Unfortunately Nokogiri doesn't support validating
  # documents with multiple namespaces.  So we have to extract the element
  # and create a new document from it.  If the xmlns isn't set on the element
  # we get an error like:
  #
  #    Element 'video': No matching global declaration available for the validation root.
  #
  # <tt>xmlns</tt> the XML namespace of the root element.
  # <tt>xml_fragment</tt> XML string
  #
  # Example:
  #   xml_fragment_should_validate('<video/>', { 'video' => 'http://www.google.com/schemas/sitemap-video/1.1' })
  def xml_fragment_should_validate_against_schema(xml, xmlns, schema_name)
    xml = xml.is_a?(String) ? xml : xml.to_s
    doc = Nokogiri::XML(xml)
    doc.root['xmlns'] = xmlns
    xml_data_should_validate_against_schema(doc, schema_name)
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
