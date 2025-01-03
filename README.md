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

NOTE: for error "requireStack: [ '/rails/node_modules/rollup/dist/native.js' ]", optional rollup dependency required for Vite in production (https://stackoverflow.com/questions/77569907/error-in-react-vite-project-due-to-rollup-dependency-module-not-found).

```sh
gem install kamal
kamal setup

# TODO: run as hooks?
# On instance:
mkdir -p /home/ubuntu/rails_storage
chown -R ubuntu:ubuntu /home/ubuntu/rails_storage
sudo chmod -R 777 /home/ubuntu/rails_storage

# (Optional) Build accessory
cd longvu_pg && ./build.sh
kamal accessory remove longvu_pg
kamal accessory boot longvu_pg

# Build app
!commit changes to git if deploy builder context is not .
# NOTE: (to fix permission issue) COPY --chmod=755 --from=build /rails /rails
kamal deploy
```

* ...
