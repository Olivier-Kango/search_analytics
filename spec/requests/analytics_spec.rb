require 'rails_helper'

RSpec.describe 'Analytics', type: :request do
  describe 'GET /analytics' do
    it 'returns top searches as JSON' do
      Search.create(query: 'What is Ruby?', ip_address: '192.168.1.1', created_at: Time.current)
      get '/analytics'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('What is Ruby?' => 1)
    end

    it 'returns empty hash when no searches exist' do
      get '/analytics'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({})
    end
  end
end
