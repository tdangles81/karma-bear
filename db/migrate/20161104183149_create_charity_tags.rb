class CreateCharityTags < ActiveRecord::Migration[5.0]
  def change
    create_table :charity_tags do |t|
      t.integer :tag_id
      t.integer :charity_id

      t.timestamps
    end
  end
end
