require 'spec_helper'

describe 'SitemapGenerator::AwsSdkAdapter' do
  let(:location) { SitemapGenerator::SitemapLocation.new }
  let(:adapter)  { SitemapGenerator::AwsSdkAdapter.new(options) }
  let(:options) { {} }

  describe 's3_resource_options' do
    it 'does not include region' do
      expect(adapter.s3_resource_options[:aws_region]).to be_nil
    end

    it 'does not include credentials' do
      expect(adapter.s3_resource_options[:aws_access_key_id]).to be_nil
      expect(adapter.s3_resource_options[:aws_secret_access_key]).to be_nil
    end

    context 'with AWS region option' do
      let(:options) { { aws_region: 'region' } }

      it 'includes the region' do
        expect(adapter.s3_resource_options[:aws_region]).to eql('region')
      end
    end

    context 'with AWS credentials' do
      let(:options) do
        {
          aws_access_key_id: 'access_id',
          aws_secret_access_key: 'secret_key'
        }
      end

      it 'includes the credentials' do
        options = adapter.s3_resource_options
        expect(options[:aws_access_key_id]).to eql('access_id')
        expect(options[:aws_secret_access_key]).to eql('secret_key')
      end
    end
  end
end
