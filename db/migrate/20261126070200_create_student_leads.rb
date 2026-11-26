class CreateStudentLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :student_leads do |t|
      t.references :project, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false, limit: 120
      t.string :program, null: false, limit: 120
      t.integer :semester, null: false
      t.string :email, null: false, limit: 160

      t.timestamps
    end

    add_check_constraint :student_leads, "semester BETWEEN 1 AND 12", name: "student_leads_semester_range"
  end
end
