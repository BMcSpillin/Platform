class ChangeZiptoString < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :zip
      t.string :zip5
      t.string :zip4
    end
  end
end
