# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

rspec の実行方法

```sh
./bin/rspec
```

管理者アカウント作成

```sh
rails db:seed ADMIN_EMAIL="[email]" ADMIN_PASSWORD="[password]"
```
