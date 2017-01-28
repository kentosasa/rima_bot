# Rima-san
![Rails](https://img.shields.io/badge/Rails-5.0.1-orange.svg) ![Ruby](https://img.shields.io/badge/Ruby-2.3.0-red.svg)
![LINE BOT](https://img.shields.io/badge/LINE%20BOT--brightgreen.svg)

会話から日付を認識してリマインドや日程調整のサポートをするリマインドBOT on LINE.

## Description

***DEMO:***
[Demo](https://www.youtube.com/watch?v=FRZqDVY_j-c)

## Features

- Not Aware Bot
- Awesome UI
- One tap Remind

## Requirement

|     |version|
|:---:|:----:|
|Ruby|2.3.0|
|Rails|5.0.1|
|Bulma||
|SCSS||
|Postgres||
|datte|0.6.2|

## Usage

### Install
```
git clone https://github.com/kentosasa/rima_san.git
cd rima_san
docker-compose build  # コンテナ作成
docker-compose up     # コンテナ起動
```

### Setup

```
docker-compose run web rails db:create  # DB作成
docker-compose run web rails db:migrate # DB構築
```

## Installation

    $ git clone https://github.com/kentosasa/rima_san.git

## Author

- [@pokohide](https://github.com/hyde2able)
- [@kentosasa](https://github.com/kentosasa)

## License

[MIT](http://b4b4r07.mit-license.org)
