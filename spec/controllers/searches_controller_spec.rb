require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'POST #create' do
    let(:ip) { '192.168.1.1' }

    before { allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip) }

    it 'creates a new search for valid query' do
      post :create, params: { query: 'What i s' }, as: :json
      expect(response).to have_http_status(:ok)
      expect(Search.count).to eq(1)
      expect(Search.first.query).to eq('What i s')
      expect(Search.first.ip_address).to eq(ip)
    end

    it 'returns bad request for blank query' do
      post :create, params: { query: '' }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end

    it 'returns bad request for short query' do
      post :create, params: { query: 'ab' }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(Search.count).to eq(0)
    end
  end
end
