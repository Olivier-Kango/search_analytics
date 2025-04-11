class AddIndexesToSearches < ActiveRecord::Migration[7.0]
  def change
    add_index :searches, :ip_address
    add_index :searches, :created_at
  end
end
