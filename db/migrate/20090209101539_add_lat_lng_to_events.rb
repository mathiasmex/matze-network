class AddLatLngToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :lat, :float, :default => 0.0
    add_column :events, :lng, :float, :default => 0.0

    Event.find(:all) do |event|
      event.lat = 0.0
      event.lng = 0.0
      event.save!
    end
  end

  def self.down
    remove_column :events, :lng
    remove_column :events, :lat
  end
end
