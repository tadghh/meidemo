# Setup

## DB
```sh
sudo -u postgres psql -c "CREATE USER msearch_db_user WITH PASSWORD 'msearch_password';"
sudo -u postgres psql -c "ALTER USER msearch_db_user CREATEDB;"
```

## Meilisearch Server
```sh
curl -L https://install.meilisearch.com | sh
```
## Docker
```sh
git clone https://github.com/tadghh/meidemo.git;
cd ./meidemo/;
docker build . -t mei_search_rails:demo;
docker run -p 3000:3000 mei_search_rails:demo;
# To exit container SIGTERM * 3 (crtl+c)
```