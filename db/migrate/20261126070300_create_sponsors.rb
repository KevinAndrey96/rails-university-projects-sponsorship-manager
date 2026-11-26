class CreateSponsors < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsors do |t|
      t.string :name, null: false, limit: 150
      t.integer :kind, null: false
      t.string :nit, null: false, limit: 11
      t.string :phone, null: false, limit: 10
      t.string :email, null: false, limit: 160

      t.timestamps
    end

    add_index :sponsors, :nit, unique: true
  end
end
