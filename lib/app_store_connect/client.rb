# frozen_string_literal: true

require 'active_support/all'

require 'app_store_connect/request'
require 'app_store_connect/schema'
require 'app_store_connect/client/authorization'
require 'app_store_connect/client/options'
require 'app_store_connect/client/usage'
require 'app_store_connect/client/registry'
require 'app_store_connect/client/utils'

module AppStoreConnect
  class Client
    def initialize(**kwargs)
      @options = Options.new(kwargs)
      @usage = Usage.new(@options.slice(*Usage::OPTIONS))
      @authorization = Authorization.new(@options.slice(*Authorization::OPTIONS))
      @registry = Registry.new(@options.slice(*Registry::OPTIONS))
    end

    def respond_to_missing?(method_name, include_private = false)
      endpoint_by(operation_id: method_name.to_s) || super
    end

    def method_missing(method_name, *kwargs)
      endpoint = endpoint_by(operation_id: method_name.to_s)

      super if endpoint.nil?

      call(endpoint, *kwargs)
    end

    # :nocov:
    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end
    # :nocov:

    private

    def endpoint_by(operation_id:)
      @options[:schema].endpoint_by(operation_id: operation_id)
    end

    def call(endpoint, **kwargs)
      request = build_request(endpoint, **kwargs)

      @usage.track
      response = request.execute

      Utils.decode(response.body, response.content_type) if response.body
    end

    def server_url
      @options[:schema].url
    end 

    def build_uri(endpoint, kwargs)
      without_query = String.new("#{server_url}#{endpoint.path.path}")
        .gsub(/(\{(\w+)\})/) { kwargs.fetch(Regexp.last_match(2).to_sym) }

      URI(without_query).tap do |uri|
        uri.query = build_query(endpoint, kwargs)
      end
    end
    
    def build_query(endpoint, kwargs)
      kwargs
        .deep_transform_keys(&:to_s)
        .slice(*endpoint.query_parameters.map(&:name))
        .to_query
    end 

    def web_service_endpoint_by(alias_sym)
      @registry[alias_sym]
    end

    def build_request_body(endpoint, **kwargs)
      {}
      # Utils.encode("AppStoreConnect::#{web_service_endpoint.http_body_type}"
        # .constantize
        # .new(**kwargs)
        # .to_h)
    end

    def build_request(endpoint, **kwargs)
      options = {
        kwargs: kwargs,
        http_method: endpoint.method.to_sym,
        uri: build_uri(endpoint, **kwargs),
        headers: headers
      }

      options[:http_body] = build_request_body(endpoint, *kwargs) if endpoint.method.to_sym == :post

      Request.new(options)
    end

    def headers
      {
        'Authorization' => "Bearer #{@authorization.token}",
        'Content-Type' => 'application/json'
      }
    end
  end
end
