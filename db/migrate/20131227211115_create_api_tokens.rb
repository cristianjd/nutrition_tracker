class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :auth_token
      t.string :auth_secret
      t.string :provider
      t.integer :user_id

      t.timestamps
    end
  end
end
