class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.boolean :active

      t.timestamps
    end
  end
end
