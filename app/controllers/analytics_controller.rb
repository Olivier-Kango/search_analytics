class AnalyticsController < ApplicationController
  def index
    searches_by_ip = Search.order(:created_at).group_by(&:ip_address)

    final_queries = []

    searches_by_ip.each do |ip, searches|
      current_sequence = []

      searches.each_with_index do |search, idx|
        if current_sequence.empty?
          current_sequence << search
          next
        end

        time_diff = search.created_at - current_sequence.last.created_at
        is_continuation = search.query.start_with?(current_sequence.last.query) && time_diff <= 8

        if is_continuation
          current_sequence << search
        else
          final_queries << current_sequence.last.query
          current_sequence = [search]
        end
      end

      final_queries << current_sequence.last.query unless current_sequence.empty?
    end

    top_searches = final_queries.each_with_object(Hash.new(0)) { |q, h| h[q] += 1 }
                               .sort_by { |_, v| -v }
                               .first(10)
                               .to_h

    render json: top_searches
  end
end
