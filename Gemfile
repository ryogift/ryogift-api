source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

gem "rails", "6.1.4.4"
gem "pg", "1.2.3"
gem "puma", "5.5.2"
gem "bcrypt", "3.1.16"
gem "bootsnap", "1.9.3", require: false
gem "rack-cors", "1.1.1"
gem "net-smtp", require: false

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop", require: false
  gem "pry-rails"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "parallel_tests"
end

group :development do
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "spring-commands-rspec"
  gem "letter_opener_web"
end

group :test do
  gem "test-prof"
  gem "stackprof", require: false
end
