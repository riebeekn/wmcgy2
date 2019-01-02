class AddIncludeInBudgetToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :include_in_budget, :boolean, :default => true
  end
end
