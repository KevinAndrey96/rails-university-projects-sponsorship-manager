class CreateTutors < ActiveRecord::Migration[8.1]
  def change
    create_table :tutors do |t|
      t.string :name, null: false, limit: 120
      t.string :faculty, null: false, limit: 120
      t.string :email, null: false, limit: 160

      t.timestamps
    end

    add_index :tutors, :email, unique: true
  end
end
