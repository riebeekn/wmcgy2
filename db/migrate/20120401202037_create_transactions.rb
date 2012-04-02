class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :description
      t.date :date
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0.0
      t.boolean :is_debit
      t.integer :category_id
      t.integer :user_id

      t.timestamps
    end
    add_index :transactions, [:user_id]
  end
end
