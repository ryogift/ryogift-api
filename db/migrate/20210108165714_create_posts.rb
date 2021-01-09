class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false
      t.string :content
      t.integer :state
      t.datetime :published_at

      t.timestamps
    end
  end
end
