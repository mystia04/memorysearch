class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |memories|
      memories.string :mem_id
      memories.text :sf_station
      memories.text :in_station
      memories.timestamps
    end
  end
end
