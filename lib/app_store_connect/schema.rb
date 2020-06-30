# frozen_string_literal: true

require 'app_store_connect/schema/type'
require 'app_store_connect/schema/object'
require 'app_store_connect/schema/web_service_endpoint'

require 'json'
require 'oas_parser'
require 'forwardable'

module AppStoreConnect
  class Schema
		extend Forwardable

    attr_reader :types, :web_service_endpoints, :objects

    def initialize(path)
      @definition = OasParser::Definition.resolve(path)

      @web_service_endpoints = []
      @objects = []
      @types = []
    end

		def_delegators :@definition, :paths

    def url 
      @definition.servers.first["url"]
    end 
		
		#
		# @return [Array<String>]
		def operation_ids
			paths.flat_map do |path|
				path.raw.values.map { |v| v["operationId"] }
			end.compact
		end 

		#
		# @param operation_id [String]
		# 
		# @return [OasParser::Path?] 
		def path_by(operation_id:)
			paths.detect do |path|
				path.raw.values.any? do |options|
					options["operationId"] == operation_id
				end 
			end 
		end 

		#
		# @param operation_id [String]
		# 
		# @return [OasParser::Endpoint?] 
		def endpoint_by(operation_id:)
			path = path_by(operation_id: operation_id)

			return if path.nil?
			
			path.endpoints.detect do |endpoint|
				endpoint.raw["operationId"] == operation_id
			end 	
		end 
  end
end
