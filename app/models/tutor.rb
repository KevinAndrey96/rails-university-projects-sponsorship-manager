class Tutor < ApplicationRecord
  has_many :projects, dependent: :nullify

  normalizes :name, :faculty, with: ->(value) { value.squish }
  normalizes :email, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 120 }
  validates :faculty, presence: true, length: { maximum: 120 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 160 },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
