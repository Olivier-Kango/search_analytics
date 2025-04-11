class AnalyticsController < ApplicationController
  def index
    final_queries = get_final_queries
    top_searches = final_queries.each_with_object(Hash.new(0)) { |q, h| h[q] += 1 }
                        .sort_by { |k, v| -v }
                        .first(10)
                        .to_h
    render json: top_searches
  end

  private

  def get_final_queries
    final_queries = []
    searches_by_ip = Search.all.to_a.group_by(&:ip_address)
    searches_by_ip.each do |ip, searches|
      searches = searches.sort_by(&:created_at)
      current_sequence = []
      searches.each do |search|
        if current_sequence.empty? || !is_continuation?(current_sequence.last.query.to_s.strip,
                                                        search.query.to_s.strip,
                                                        search.created_at - current_sequence.last.created_at)
          final_queries << current_sequence.last.query unless current_sequence.empty?
          current_sequence = [search]
        else
          current_sequence << search
        end
      end
      final_queries << current_sequence.last.query unless current_sequence.empty?
    end
    final_queries.compact.uniq
  end

  def is_continuation?(last_query, new_query, time_diff)
    new_query.start_with?(last_query) && time_diff <= 8.seconds
  end
end
