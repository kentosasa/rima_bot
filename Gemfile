source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'dotenv-rails'
gem 'haml-rails'
gem 'erb2haml'
gem 'rb-readline'
gem 'annotate'

gem 'rails', '~> 5.0.1'
gem 'puma', '~> 3.0'

## Frontend
gem 'slim-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bulma-rails', "~> 0.3.0"
gem "font-awesome-rails"
gem 'gon'

gem 'meta-tags'

## lib
gem 'line-bot-api'
gem 'datte'

# DB
gem 'sqlite3'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
