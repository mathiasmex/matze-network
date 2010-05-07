class ReorderPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :people, :phone, :integer
    add_column :preferences, :node_number, :integer, :default => 3, :null => false
    add_column :preferences, :number_of_companies, :integer, :default => 3, :null => false
  end

  def self.down
    remove_column :people, :phone
    remove_column :preferences, :node_number
    remove_column :preferences, :number_of_companies
  end
end
