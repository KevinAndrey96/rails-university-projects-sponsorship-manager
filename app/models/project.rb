class Project < ApplicationRecord
  enum :status, { proposed: 0, in_progress: 1, completed: 2 }, validate: true

  belongs_to :tutor, optional: true
  has_one :student_lead, dependent: :destroy
  has_many :sponsorships, dependent: :destroy
  has_many :sponsors, through: :sponsorships

  broadcasts_refreshes

  normalizes :title, with: ->(value) { value.squish }

  before_validation { self.title_key = self.class.title_key_for(title) }

  validates :title, presence: true, length: { maximum: 150 }
  validate :title_not_taken
  validates :summary, presence: true, length: { maximum: 3_000 }
  validates :budget, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(:title) }
  scope :with_funding, -> {
    left_joins(:sponsorships)
      .select("projects.*, COALESCE(SUM(sponsorships.amount), 0) AS funded_total")
      .group("projects.id")
  }

  # SQLite LOWER() only folds ASCII, so uniqueness compares a transliterated, downcased key instead.
  def self.title_key_for(title)
    I18n.transliterate(title.to_s).downcase.squish
  end

  def funded_amount
    has_attribute?(:funded_total) ? self[:funded_total].to_i : sponsorships.sum(:amount)
  end

  def funding_ratio
    funded_amount.fdiv(budget)
  end

  def remaining_amount
    [ budget - funded_amount, 0 ].max
  end

  def fully_funded?
    funded_amount >= budget
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  private
    def title_not_taken
      return if title_key.blank?

      errors.add(:title, :taken, value: title) if Project.where.not(id: id).exists?(title_key: title_key)
    end
end
