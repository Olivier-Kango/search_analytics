class SearchesController < ApplicationController
  def create
    ip = request.remote_ip
    query = params[:query].to_s.strip

    return head :bad_request if query.blank? || query.length < 3

    last = Search.where(ip_address: ip).order(updated_at: :desc).first

    if last && recent?(last) && query.start_with?(last.query)
      last.update(query: query)
    else
      Search.create(query: query, ip_address: ip)
    end

    head :ok
  end

  private

  def recent?(search)
    Time.current - search.updated_at <= 5.seconds
  end
end
