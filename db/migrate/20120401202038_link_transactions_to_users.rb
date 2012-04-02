# Assumes PostgreSQL
class LinkTransactionsToUsers < ActiveRecord::Migration
  def self.up
    execute "
      ALTER TABLE transactions 
        ADD CONSTRAINT fk_transactions_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE"
  end

  def self.down
    execute "ALTER TABLE transactions DROP CONSTRAINT fk_transactions_user_id"
  end
end
