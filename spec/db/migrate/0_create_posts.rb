class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :score
      t.boolean :published, default: false
      t.timestamps
    end
  end
end
