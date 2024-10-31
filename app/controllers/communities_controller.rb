class CommunitiesController < ApplicationController
  before_action :set_results, only: [ :search ]

  def index
  end

  def search
    respond_to do |format|
      format.json do
        render json: @results
      end
    end
  end

  private

  def set_results
      @search_query = params[:query] || ""

      @results = perform_search(@search_query)
  end


  def perform_search(query)
    multi_search_results = MeiliSearch::Rails.multi_search(
      "SiteCommunities" => { q: query },
      "SitePosts" => { q: query }
    )

    # Process the results into a structured format
    # These values are made up of the searchable attribtues listed in the model files
    multi_search_results.map do |result|
      if result["title"]
        {  title: result["title"],  content: result["content"] }
      else
        { name: result["name"],  description: result["description"]  }
      end
    end.compact
  end
end
