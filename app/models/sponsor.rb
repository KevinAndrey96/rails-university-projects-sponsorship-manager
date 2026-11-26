class Sponsor < ApplicationRecord
  # Colombian numbering plan since 2021: mobiles start with 3 and landlines with 60, both with ten digits.
  PHONE_FORMAT = /\A(3\d{9}|60\d{8})\z/

  enum :kind, { company: 0, ngo: 1, public_entity: 2, university: 3 }, validate: true

  has_many :sponsorships, dependent: :restrict_with_error
  has_many :projects, through: :sponsorships

  normalizes :name, with: ->(value) { value.squish }
  normalizes :nit, with: ->(value) { value.delete(" .") }
  normalizes :phone, with: ->(value) { value.gsub(/\D/, "").sub(/\A57(?=\d{10}\z)/, "") }
  normalizes :email, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 150 }
  validates :nit, uniqueness: true, nit: true
  validates :phone, format: { with: PHONE_FORMAT }
  validates :email, presence: true, length: { maximum: 160 }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :ordered, -> { order(:name) }

  def committed_amount
    sponsorships.sum(:amount)
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
