class AddClientIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :client_id, :string
  end
end
