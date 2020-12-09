source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.0"

gem "rails", "6.0.3.4"
gem "pg", "1.2.3"
gem "puma", "4.3.7"
gem "jbuilder", "2.10.0"
gem "bcrypt", "3.1.7"
gem "bootsnap", "1.4.8", require: false
gem "rack-cors", "1.1.1"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop", "0.89.1", require: false
  gem "pry-rails"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "simplecov", "0.18.5", require: false
end

group :development do
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "spring-commands-rspec"
  gem "letter_opener_web"
end
