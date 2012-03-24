# Assumes PostgreSQL
class LinkCategoriesToUsers < ActiveRecord::Migration
  def self.up
    execute "
      ALTER TABLE categories 
        ADD CONSTRAINT fk_categories_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE"
  end

  def self.down
    execute "ALTER TABLE categories DROP CONSTRAINT fk_categories_user_id"
  end
end
