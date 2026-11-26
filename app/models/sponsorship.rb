class Sponsorship < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :sponsor

  validates :amount, numericality: { only_integer: true, greater_than: 0 }
  validates :committed_on, presence: true
  validates :sponsor, uniqueness: { scope: :project_id }

  scope :recent, -> { order(committed_on: :desc, id: :desc) }
end
