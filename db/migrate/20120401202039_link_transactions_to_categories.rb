# Assumes PostgreSQL
class LinkTransactionsToCategories < ActiveRecord::Migration
  def self.up
    execute "
      ALTER TABLE transactions 
        ADD CONSTRAINT fk_transactions_category_id
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE"
  end

  def self.down
    execute "ALTER TABLE transactions DROP CONSTRAINT fk_transactions_category_id"
  end
end
