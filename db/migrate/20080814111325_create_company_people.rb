class CreateCompanyPeople < ActiveRecord::Migration
  def self.up
    create_table :company_people do |t|
      t.integer :person_id
      t.integer :company_id

      t.timestamps
    end
  end

  def self.down
    drop_table :company_people
  end
end
