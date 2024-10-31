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
