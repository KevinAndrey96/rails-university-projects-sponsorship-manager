# Validates a Colombian NIT written as "#########-D", checking the DIAN verification digit.
class NitValidator < ActiveModel::EachValidator
  FORMAT = /\A(\d{9})-(\d)\z/
  WEIGHTS = [ 3, 7, 13, 17, 19, 23, 29, 37, 41 ].freeze

  def self.check_digit(base)
    sum = base.to_s.reverse.chars.each_with_index.sum { |digit, index| digit.to_i * WEIGHTS.fetch(index) }
    remainder = sum % 11

    remainder > 1 ? 11 - remainder : remainder
  end

  def self.valid?(value)
    match = FORMAT.match(value.to_s)

    match.present? && check_digit(match[1]) == match[2].to_i
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_nit) unless self.class.valid?(value)
  end
end
