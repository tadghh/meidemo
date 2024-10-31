class Post < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :community


  meilisearch index_uid: "SitePosts" do
    attribute [ :title, :content ]
  end
end
