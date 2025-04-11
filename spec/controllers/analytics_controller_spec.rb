require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do
  describe 'GET #index' do
    let(:ip1) { '192.168.1.1' }
    let(:ip2) { '192.168.1.2' }

    context 'with progressive sequences' do
      before do
        Timecop.freeze(Time.current) do
          # IP1 types a progressive query
          Search.create(query: 'What is', ip_address: ip1, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'What is a', ip_address: ip1, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'What is a good car', ip_address: ip1, created_at: Time.current)

          # IP2 types another progressive query
          Timecop.travel(3.seconds)
          Search.create(query: 'How is', ip_address: ip2, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'How is Emil Hajric', ip_address: ip2, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'How is Emil Hajric doing', ip_address: ip2, created_at: Time.current)
        end
      end

      it 'returns only the final and most relevant queries per user' do
        get :index
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data).to eq(
          'What is a good car' => 1,
          'How is Emil Hajric doing' => 1
        )
      end
    end

    context 'with identical final queries from different IPs' do
      before do
        Timecop.freeze(Time.current) do
          # IP1: Progressive sequence
          Search.create(query: 'What is', ip_address: ip1, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'What is a good car', ip_address: ip1, created_at: Time.current)

          # IP2: Same final query
          Search.create(query: 'What is', ip_address: ip2, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'What is a good car', ip_address: ip2, created_at: Time.current)
        end
      end

      it 'includes each unique final query once' do
        get :index
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data).to eq('What is a good car' => 1)
      end
    end

    context 'with non-continuous sequences' do
      before do
        Timecop.freeze(Time.current) do
          # IP1: Non-continuous queries
          Search.create(query: 'What', ip_address: ip1, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'How to code', ip_address: ip1, created_at: Time.current)
        end
      end

      it 'returns both queries' do
        get :index
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data).to eq(
          'What' => 1,
          'How to code' => 1
        )
      end
    end

    context 'with prefix queries across different IPs' do
      before do
        Timecop.freeze(Time.current) do
          # IP1: Short query
          Search.create(query: 'What', ip_address: ip1, created_at: Time.current)

          # IP2: Longer query starting with the same prefix
          Search.create(query: 'What is', ip_address: ip2, created_at: Time.current)
          Timecop.travel(3.seconds)
          Search.create(query: 'What is life', ip_address: ip2, created_at: Time.current)
        end
      end

      it 'removes prefix queries' do
        get :index
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data).to eq('What is life' => 1)
      end
    end

    context 'when no searches exist' do
      before { Search.destroy_all }

      it 'returns an empty hash' do
        get :index
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)

        expect(data).to eq({})
      end
    end
  end
end
