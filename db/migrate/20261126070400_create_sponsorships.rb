class CreateSponsorships < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsorships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true
      t.bigint :amount, null: false
      t.date :committed_on, null: false

      t.timestamps
    end

    add_index :sponsorships, %i[project_id sponsor_id], unique: true
    add_check_constraint :sponsorships, "amount > 0", name: "sponsorships_amount_positive"
  end
end
