require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do
  describe 'GET #index' do
    let(:ip1) { '192.168.1.1' }
    let(:ip2) { '192.168.1.2' }

    before do
      Timecop.freeze(Time.current) do
        Search.create(query: 'What i s', ip_address: ip1, created_at: Time.current)
        Timecop.travel(3.seconds)
        Search.create(query: 'What i s ', ip_address: ip1, created_at: Time.current)
        Timecop.travel(3.seconds)
        Search.create(query: 'What i s ', ip_address: ip1, created_at: Time.current)

        Timecop.travel(10.seconds)
        Search.create(query: 'How i ', ip_address: ip2, created_at: Time.current)
        Timecop.travel(3.seconds)
        Search.create(query: 'How i emil hajric', ip_address: ip2, created_at: Time.current)
        Timecop.travel(3.seconds)
        Search.create(query: 'How i emil hajric doing', ip_address: ip2, created_at: Time.current)
      end
    end

    it 'retourne les recherches finales les plus fréquentes' do
      get :index
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.keys).to contain_exactly('What i s ', 'How i emil hajric doing')
    end
  end
end
