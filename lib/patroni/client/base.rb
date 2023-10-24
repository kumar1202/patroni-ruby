# frozen_string_literal: true

module Patroni
  module Client
    # This is the base implementation of the Patroni REST API
    class Base
      attr_accessor :errors
      def initialize(host: "localhost", port: "8008", options: {})
        @host = host
        @port = port
        @options = options
        @errors = []
      end

      def primary?
        head_method("/primary")
      end
      

      def standby_leader?
        head_method("/standby-leader")
      end

      def leader?
        head_method("/leader")
      end

      private

      def head_method(path, query_params: {})
        begin
          response = http_client.head(path)
        rescue  => e
          @errors.append("Response Error. Error: #{e.message}")
        end

        return true if response[:code] == 200
        return false
      end

      def base_url
        return "https://#{@host}#{@port}" if @options[:ssl_enabled]

        "http://#{@host}#{@port}"
      end

      def http_client
        HttpMethods.new(base_url, @options[:max_retries], @options[:timeout])
      end
    end
  end
end
