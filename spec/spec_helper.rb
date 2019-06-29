# frozen_string_literal: true

require 'bundler/setup'
require 'app_store_connect'
require 'factory_bot'
require 'webmock/rspec'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    stub_request(:any, /api.appstoreconnect.apple.com/)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
