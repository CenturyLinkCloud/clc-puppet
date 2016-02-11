source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'faraday'
gem 'faraday_middleware'
gem 'facter', '>= 1.7.0'
gem 'hocon'

group :test do
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'metadata-json-lint'
  gem 'rspec-puppet'
  gem 'webmock'
  gem 'vcr'
end
