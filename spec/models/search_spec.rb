require 'rails_helper'

RSpec.describe Search, type: :model do
  it 'is valid with query and ip_address' do
    expect(Search.new(query: 'What is Ruby?', ip_address: '192.168.1.1')).to be_valid
  end

  it 'is invalid without query' do
    search = Search.new(ip_address: '192.168.1.1')
    expect(search).not_to be_valid
    expect(search.errors[:query]).to include("can't be blank")
  end

  it 'is invalid without ip_address' do
    search = Search.new(query: 'What is Ruby?')
    expect(search).not_to be_valid
    expect(search.errors[:ip_address]).to include("can't be blank")
  end
end
