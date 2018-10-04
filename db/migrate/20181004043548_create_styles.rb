class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string :style_name
      t.string :size
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
