class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :auth_token
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.string :activation_token
      t.datetime :activation_sent_at
      t.boolean :active

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
