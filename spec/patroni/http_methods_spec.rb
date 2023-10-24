# spec/http_methods_spec.rb

require_relative '../../lib/patroni/http_methods' # Include the HttpMethods class
require 'webmock/rspec' # Mock HTTP requests

RSpec.describe HttpMethods do
  let(:base_url) { 'http://localhost:8008' }
  let(:api) { HttpMethods.new(base_url) }

  describe '#get' do
    it 'performs a GET request' do
      stub_request(:get, "#{base_url}/leader").to_return(status: 200, body: '{"message":"Success"}')
      response = api.get('/leader')
      expect(response).to be_instance_of(Hash)
      expect(response['message']).to eq('Success')
    end
  end

  describe '#head' do
    it 'performs a HEAD request' do
      stub_request(:head, "#{base_url}/leader").to_return(status: 200)
      response = api.head('/leader')
      expect(response).to be_nil
    end
  end

  describe '#post' do
    it 'performs a POST request' do
      data = { key: 'value' }
      stub_request(:post, "#{base_url}/config").with(body: data.to_json).to_return(status: 201, body: '{}')
      response = api.post('/config', data)
      expect(response).to be_instance_of(Hash)
    end
  end

  describe '#put' do
    it 'performs a PUT request' do
      data = { key: 'new_value' }
      stub_request(:put, "#{base_url}/config").with(body: data.to_json).to_return(status: 204)
      response = api.put('/config', data)
      expect(response).to be_nil
    end
  end

  describe '#delete' do
    it 'performs a DELETE request' do
      stub_request(:delete, "#{base_url}/failover").to_return(status: 204)
      response = api.delete('/failover')
      expect(response).to be_nil
    end
  end
end
