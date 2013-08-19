source 'http://rubygems.org'

if RUBY_VERSION =~ /1.9/
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
end

gem 'nokogiri'
gem 'json', '~> 1.7.7'
gem 'roar', '~> 0.9.1'
gem 'erubis', '~> 2.7.0'
gem 'sinatra', '~> 1.3.1'
gem 'thin', '~> 1.3.1'
gem 'rake'

# Data Storage
gem 'mongo', '1.8.3'
gem 'mongo_ext', '~> 0.19', :platform => :ruby # native extensions for performance
gem 'bson_ext', '1.8.3', :platform => :ruby  # native extensions for performance
gem 'bson', '1.8.3'
gem 'mongoid', '2.4.3'

# CLI and Offline documentation generator
gem 'httparty', '~> 0.8.1'
gem 'activemodel', '~> 3.2.0'
gem 'source2swagger'
# Account/Auth support
gem 'bcrypt-ruby', '~> 3.0.1'

# API Doc generation
gem 'redcarpet', '~> 2.1.0'

# Cloud Management
gem 'fog', '1.15.0', :require => 'fog'
gem 'rb-readline'
gem 'debugger'

gem "rest-client", "~> 1.6.7"
gem "spice"
#Should use ridley instead of spice, but ridley and mongoid are currently incompatible until mongoid 4.0 release or fixes with Ridley for Boolean class definition.
#gem "ridley", "~>1.5.0"


# Flex support hack - allow _method to be passed as a URL parameter for PUT and DELETE
gem 'rack-methodoverride-with-params', '~>1.0.0'

# Test-only
group :development, :test do
  gem 'rspec', '~> 2.4'
  gem 'heroku'
  gem 'foreman'
  gem 'rack-test'
  gem 'awesome_print'
  gem 'database_cleaner'
  gem 'factory_girl', '~> 3.0.0'
end

# Google
gem 'google-api-client'
