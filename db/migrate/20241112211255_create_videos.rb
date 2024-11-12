class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.string :uuid
      t.json :metadata

      t.timestamps
    end
  end
end
