class AnalyticsController < ApplicationController
  def index
    top_searches = Search.group(:query)
                         .order('count_all DESC')
                         .limit(10)
                         .count

    render json: top_searches
  end
end
