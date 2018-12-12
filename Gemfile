source 'https://rubygems.org'
gem 'sinatra'
gem 'stripe'
gem 'data_mapper'
gem 'sinatra-flash'
# fixes ssl issues
gem 'certified', '~> 1.0'
# helps make http requests
gem 'httparty', '~> 0.13.7'

group :development do
  gem "sqlite3-ruby"
  gem "dm-sqlite-adapter"
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end
