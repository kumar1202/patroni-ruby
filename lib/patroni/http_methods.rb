# frozen_string_literal: true

require "net/http"
require "json"

#  This class implements the basic http methods with response handling and retry mechanism
class HttpMethods
  def initialize(base_url, max_retries = 3, timeout = 10)
    @base_url = base_url
    @max_retries = max_retries
    @timeout = timeout
    @errors = []
  end

  def get(path)
    execute_with_retry do
      uri = URI.join(@base_url, path)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.get(uri)
      end

      handle_response(response)
    end
  end

  def head(path)
    execute_with_retry do
      uri = URI.join(@base_url, path)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.head(uri)
      end

      handle_response(response)
    end
  end

  def post(path, data)
    execute_with_retry do
      uri = URI.join(@base_url, path)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = data.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.request(request)
      end
    end
  end

  def put(path, data)
    execute_with_retry do
      uri = URI.join(@base_url, path)
      request = Net::HTTP::Put.new(uri)
      request["Content-Type"] = "application/json"
      request.body = data.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.request(request)
      end

      handle_response(response)
    end
  end

  def delete(path)
    execute_with_retry do
      uri = URI.join(@base_url, path)
      request = Net::HTTP::Delete.new(uri)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.request(request)
      end

      handle_response(response)
    end
  end

  private

  def execute_with_retry
    retry_count = 0
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      retry_count += 1
      if retry_count <= @max_retries
        puts("Request failed with error: #{e.message}. Retrying (attempt #{retry_count})...") && retry
      end
      raise "Max retries reached. Error: #{e.message}" if retry_count >= @max_retries
    rescue StandardError => e
      raise "Unknown Error Occured. Error: #{e.message}"
    end
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      return {code: response.code}  if response.body.empty?
      return {body: JSON.parse(response.body), code: response.code}  if response.body && !response.body.empty?
    when Net::HTTPClientError, Net::HTTPServerError
      raise "HTTP Error: #{response.code} - #{response.message}"
    else
      raise "Unknown response: #{response.code} - #{response.message}"
    end
  end
end
