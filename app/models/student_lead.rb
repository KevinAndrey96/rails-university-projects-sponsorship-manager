class StudentLead < ApplicationRecord
  belongs_to :project, touch: true

  normalizes :name, :program, with: ->(value) { value.squish }
  normalizes :email, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 120 }
  validates :program, presence: true, length: { maximum: 120 }
  validates :semester, numericality: { only_integer: true, in: 1..12 }
  validates :email, presence: true, length: { maximum: 160 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :project, uniqueness: true
end
