class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :activation_digest
      t.string :reset_digest
      t.datetime :activated_at
      t.datetime :reset_sent_at
      t.datetime :locked_at
      t.boolean :admin, default: false
      t.integer :state, default: 0

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
