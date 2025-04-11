class SearchesController < ApplicationController
  def create
    ip = request.remote_ip
    query = params[:query].to_s.strip

    return head :bad_request if query.blank? || query.length < 3

    Search.create(query: query, ip_address: ip)

    head :ok
  end
end
