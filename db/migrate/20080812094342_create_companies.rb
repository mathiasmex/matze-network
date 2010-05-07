class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.integer :parent_id, :default => 0, :null => false
      t.string :name
      t.text :description
      t.string :web

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
