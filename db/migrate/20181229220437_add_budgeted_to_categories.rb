class AddBudgetedToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :budgeted, :decimal, :precision => 10, :scale => 2, :default => 0.0
  end
end
