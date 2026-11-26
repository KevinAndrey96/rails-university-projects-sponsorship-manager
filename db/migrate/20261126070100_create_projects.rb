class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :tutor, foreign_key: true
      t.string :title, null: false, limit: 150
      t.string :title_key, null: false, limit: 150
      t.text :summary, null: false
      t.integer :status, null: false, default: 0
      t.bigint :budget, null: false
      t.date :starts_on

      t.timestamps
    end

    add_index :projects, :title_key, unique: true
    add_index :projects, :status
    add_check_constraint :projects, "budget > 0", name: "projects_budget_positive"
  end
end
