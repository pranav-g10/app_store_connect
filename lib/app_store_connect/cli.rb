# frozen_string_literal: true

require 'gli'

require 'app_store_connect/version'

module AppStoreConnect
  class CLI
    extend GLI::App

    program_desc 'Here is my program description'
    version AppStoreConnect::VERSION

    flag [:i, 'issuer-id'],
         default_value: ENV['APP_STORE_CONNECT_ISSUER_ID']

    flag [:p, 'private-key'],
         default_value: ENV['APP_STORE_CONNECT_PRIVATE_KEY']

    flag [:k, 'key-id'],
         default_value: ENV['APP_STORE_CONNECT_KEY_ID']

    command 'app' do |c|
      c.flag %i[a app_id], required: true

      c.action do |_, options|
        app_id = options[:app_id]
        puts client.app(app_id).to_json
      end
    end

    command 'apps' do |c|
      c.desc 'Gets all of the apps'
      c.long_desc 'The long desc'

      c.action do |global_options, _, _|
        puts client(global_options).apps.to_json
      end
    end

    command 'builds' do |c|
      c.flag %i[a app_id], required: true

      c.action do |global_options, options|
        app_id = options[:app_id]

        puts client(global_options).builds(app_id).to_json
      end
    end

    command 'build' do |c|
      c.flag %i[a app_id], required: true
      c.switch %i[b build_id], required: true

      c.action do |global_options, options|
        app_id = options[:app_id]
        build_id = options[:build_id]

        puts client(global_options).build(app_id, build_id).to_json
      end
    end

    def self.client(global_options)
      AppStoreConnect::Client.new(
        private_key: global_options[:private_key],
        issuer_id: global_options[:issuer_id],
        key_id: global_options[:key_id]
      )
    end
    private_class_method :client
  end
end
