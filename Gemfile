# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'dalli', '~> 2.7'
gem 'ffi', '>= 1.9.24'
gem 'logstasher', '~> 1.2'
gem 'loofah', '>= 2.2.3'
gem 'nokogiri', '>= 1.8.2'
gem 'puma', '~> 3.10'
gem 'rack-attack', '~> 5.0.1'
gem 'rack-cors', '~> 0.4'
gem 'rails', '~> 5.1.2'
gem 'rails-html-sanitizer', '>= 1.0.4'
gem 'responders', '~> 2.4'
gem 'sprockets', '>= 3.7.2'

group :development, :test do
  gem 'byebug'
  gem 'json_spec'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rails_best_practices'
  gem 'rantly'
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 3.0'
end

# Include external bundles
Dir.glob(File.join(File.dirname(__FILE__), 'Gemfile.*')) do |gemfile|
  next if gemfile.end_with?('.lock')

  eval(IO.read(gemfile), binding)
end
