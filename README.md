# README

## Install
```
git clone https://github.com/kentosasa/rima_san.git
cd rima_san
docker-compose build  # コンテナ作成
docker-compose up     # コンテナ起動
```

## Setup

```
docker-compose run web rails db:create  # DB作成
docker-compose run web rails db:migrate # DB構築
```

ruby v.2.3.0
Rails 5.0.1
CSS Framework Bulma
SCSS
rubygems datte v0.5.0
postgres

