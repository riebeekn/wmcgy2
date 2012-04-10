class ChangeDateFormatInTransactions < ActiveRecord::Migration
  def up
    change_column :transactions, :date, :datetime
  end

  def down
    change_column :transactions, :date, :date
  end
end
