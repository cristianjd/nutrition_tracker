class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.decimal :calories
      t.decimal :protein_ratio
      t.decimal :carbohydrate_ratio
      t.decimal :fat_ratio
      t.string :remember_token

      t.timestamps
    end

    add_index :users, :remember_token
  end
end
