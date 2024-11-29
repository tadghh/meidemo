ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    postgresql-common \
    libjemalloc2 \
    libvips \
    jq \
    sudo && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    RAILS_LOG_TO_STDOUT="true" \
    SECRET_KEY_BASE="dummy_key_for_assets" \
    MEILISEARCH_HOST="http://0.0.0.0:7700"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev node-gyp pkg-config python-is-python3 jq && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG NODE_VERSION=23.1.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/
RUN bundle exec rake assets:precompile

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
RUN rm -rf node_modules

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Initialize PostgreSQL and create user/database
RUN mkdir -p /var/run/postgresql && \
    mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/run/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql/data && \
    # Initialize the database cluster
    su - postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/data" && \
    # Start PostgreSQL
    su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile start" && \
    # Wait a bit for PostgreSQL to start
    sleep 5 && \
    # Create user and database
    su - postgres -c "createuser -s -r msearch_db_user" && \
    su - postgres -c "psql -c \"ALTER USER msearch_db_user WITH PASSWORD 'msearch_password';\"" && \
    su - postgres -c "psql -c \"ALTER USER msearch_db_user CREATEDB;\"" && \
    # Stop PostgreSQL (it will be started by the start script)
    su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data stop"

# Rotating API keys, this is more secure but if you arent self hosting it will cause issues
RUN openssl rand -hex 16 > /tmp/meili_master_key
# Echoing/writing the following string into /etc/environment. The 'cat' command will be evaluated when the '/etc/environment' file is loaded
RUN echo "export MEILI_MASTER_KEY=$(cat /tmp/meili_master_key)" >> /etc/environment

# Script to setup demo env, typically these would be in their own containers
COPY <<-'EOF' /rails/bin/start.sh
#!/bin/bash
# Note: not all bash scripts are compatible with sh

# loading the env 'MEILI_MASTER_KEY'
# the 'cat' command seen written above is evaluated and set here
. /etc/environment

# The env has been set above, now we can use it in the script
# Set the api key to master so we can seed db
export MEILISEARCH_API_KEY=$MEILI_MASTER_KEY

# Start postgres
su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile start"
sleep 1

if [ ! -f "./meilisearch" ]; then
    echo "Meilisearch binary not found. Downloading..."
    curl -L https://install.meilisearch.com | sh
fi

./meilisearch --no-analytics &

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

# Assign restricted api key for the frontend
export MEILISEARCH_API_KEY=$(curl -s -X GET "${MEILISEARCH_HOST}/keys" \
    -H "Authorization: Bearer ${MEILI_MASTER_KEY}" | \
    jq -r '.results[] | select(.description == "Use it to search from the frontend") | .key')

RAILS_SERVE_STATIC_FILES=true bundle exec rails server -b 0.0.0.0 -p 3000

EOF

RUN chmod +x /rails/bin/start.sh

# Expose ports
EXPOSE 3000

ENTRYPOINT ["/bin/sh", "-c", "/rails/bin/start.sh"]
