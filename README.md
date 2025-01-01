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

* Development instructions
```sh
npm i
bin/dev
```

* Deployment instructions

```sh
mkdir -p /home/ubuntu/rails_storage
chown -R ubuntu:ubuntu /home/ubuntu/rails_storage
sudo chmod -R 777 /home/ubuntu/rails_storage

# Set registry password
export KAMAL_REGISTRY_PASSWORD=${your-password}

# Build accessory
cd longvu_pg && ./build.sh
kamal accessory remove longvu_pg
kamal accessory boot longvu_pg

# Build app
kamal deploy
```

* ...
