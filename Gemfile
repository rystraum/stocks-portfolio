# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.4"

gem "coffee-rails", "~> 4.2"
gem "devise"
gem "jbuilder", "~> 2.5"
gem "minitest", "~> 5.25"
gem "pg"
gem "puma"
gem "rails", "~> 7.2.0"
gem "sass-rails", "~> 5.0"
gem "sprockets-rails"
gem "sqlite3"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "view_component"

gem "httparty"

gem "bootsnap", ">= 1.1.0", require: false
gem "dashkitty", git: "git@bitbucket.org:intelimina/dashkitty.git"

group :development, :test do
  gem "byebug", platforms: %i[mri windows]
  gem "pry"
  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-rails"
end

group :test do
  gem "simplecov", require: false
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring", ">= 3.0"
  gem "web-console", ">= 3.3.0"
end

gem "tzinfo-data", platforms: %i[windows jruby]

# gem 'webpacker', git: 'https://github.com/rails/webpacker.git'
gem "shakapacker", "~> 9.5"

gem "will_paginate", "~> 4.0"

gem "fast-mcp", "~> 1.2"

gem "ostruct", "~> 0.6.3"
