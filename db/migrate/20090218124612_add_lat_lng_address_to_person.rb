class AddLatLngAddressToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :lat, :float, :default => 0
    add_column :people, :lng, :float, :default => 0
    add_column :people, :full_address, :string
  end

  def self.down
    remove_column :people, :full_address
    remove_column :people, :lng
    remove_column :people, :lat
  end
end
