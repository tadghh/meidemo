MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "http://0.0.0.0:7700"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY", "34528d9b5c9638642b48e810da7c0499")
}
