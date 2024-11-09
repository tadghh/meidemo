# Setup

[Article](https://tadgh.dev/blog/mei-blog-post)

## Made With
- Ruby 3.3.5
- Node 23
- Rails 7.2

## Docker
```sh
git clone https://github.com/tadghh/meidemo.git;
cd ./meidemo/;
docker build . -t mei_search_rails:demo;
docker run -p 3000:3000 mei_search_rails:demo;
# To exit container SIGTERM * 3 (crtl+c)
```

# Local Initialization

## DB
```sh
sudo -u postgres psql -c "CREATE USER msearch_db_user WITH PASSWORD 'msearch_password';"
sudo -u postgres psql -c "ALTER USER msearch_db_user CREATEDB;"
```

## Meilisearch Server
```sh
curl -L https://install.meilisearch.com | sh
```

## Project
```sh
git clone git@github.com:tadghh/meidemo.git;
bundle install;
yarn install;
yarn build;
rails db:create;
rails db:migrate;
# once Meilisearch has been downloaded and configured, then you can run the seed file (rails db:seed)
```