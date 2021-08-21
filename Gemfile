source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

gem "rails", "6.1.4.1"
gem "pg", "1.2.3"
gem "puma", "5.2.2"
gem "jbuilder", "2.11.2"
gem "bcrypt", "3.1.16"
gem "bootsnap", "1.7.2", require: false
gem "rack-cors", "1.1.1"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop", "1.11.0", require: false
  gem "pry-rails"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "simplecov", "0.21.2", require: false
end

group :development do
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "spring-commands-rspec"
  gem "letter_opener_web"
end
