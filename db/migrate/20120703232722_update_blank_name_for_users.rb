class UpdateBlankNameForUsers < ActiveRecord::Migration
  def up
    User.connection.execute("UPDATE Users SET name = email WHERE name IS NULL")
  end

  def down
  end
end
