require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'POST #create' do
    let(:ip) { '192.168.1.1' }

    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip)
    end

    it 'creates a new search for a valid query' do
      post :create, params: { query: 'What is Ruby?' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(Search.count).to eq(1)
      expect(Search.first.query).to eq('What is Ruby?')
      expect(Search.first.ip_address).to eq(ip)
    end

    it 'returns bad request for blank query' do
      post :create, params: { query: '' }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end

    it 'returns bad request for query shorter than 3 characters' do
      post :create, params: { query: 'Hi' }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end

    it 'returns bad request for query with only spaces' do
      post :create, params: { query: '   ' }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end

    it 'creates a new search for a query with exactly 3 characters' do
      post :create, params: { query: 'Hey' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(Search.count).to eq(1)
      expect(Search.first.query).to eq('Hey')
      expect(Search.first.ip_address).to eq(ip)
    end
  end
end