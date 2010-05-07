class AddAddressToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :full_address, :string
  end

  def self.down
    remove_column :events, :full_address
  end
end
