require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  describe 'POST /searches' do
    it 'creates a search with valid query' do
      post '/searches', params: { query: 'What is Ruby?' }, as: :json
      expect(response).to have_http_status(:ok)
      expect(Search.count).to eq(1)
      expect(Search.last.query).to eq('What is Ruby?')
    end

    it 'returns bad request for empty query' do
      post '/searches', params: { query: '' }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end
  end
end
