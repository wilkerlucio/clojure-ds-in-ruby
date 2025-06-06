# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.4.0"

# Core dependencies
gem "zeitwerk", "~> 2.6"

# Development dependencies
group :development do
  gem "rubocop", "~> 1.60"
  gem "rubocop-performance", "~> 1.20"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 2.26"
end

# Testing dependencies
group :test do
  gem "rspec", "~> 3.12"
  gem "rspec-core", "~> 3.12"
  gem "rspec-expectations", "~> 3.12"
  gem "rspec-mocks", "~> 3.12"
end

group :development, :test do
  gem "pry", "~> 0.14"
  gem "pry-byebug", "~> 3.10"
end
