# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 4.3.3'
# JSON Web Token for authentication
gem 'jwt'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Rubocop for linting
  gem 'rubocop'
  gem 'rubocop-rails', require: false
  # Rspec for testing
  gem 'rspec-rails', '~> 3.9'
  # Ruby on Rails static analysis security tool
  gem 'brakeman'
  # Bullet to reduce the amount of database queries
  gem 'bullet'
end

group :development do
  # Better printing
  gem 'awesome_print'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Better developer console
  gem 'pry-rails'
  # A Ruby language server
  gem 'solargraph'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
