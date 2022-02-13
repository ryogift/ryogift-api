source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

gem "rails", "7.0.2.2"
gem "pg", "1.3.1"
gem "puma", "5.6.2"
gem "bcrypt", "3.1.16"
gem "bootsnap", "1.10.3", require: false
gem "rack-cors", "1.1.1"
gem "net-smtp", require: false

group :development, :test do
  gem "rubocop", require: false
  gem "pry-rails"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "parallel_tests"
end

group :development do
  gem "listen"
  gem "letter_opener_web"
end

group :test do
  gem "test-prof"
  gem "stackprof", require: false
end
