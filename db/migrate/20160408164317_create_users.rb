class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :zip

      t.timestamps null: false
    end
  end
end
