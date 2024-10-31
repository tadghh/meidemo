class Community < ApplicationRecord
  include MeiliSearch::Rails
  has_many :posts, dependent: :destroy

  meilisearch index_uid: "SiteCommunities" do
    attribute [ :name, :description ]
  end
  scope :meilisearch_import, -> { includes(:posts) }
end
