require "test_helper"

class SponsorTest < ActiveSupport::TestCase
  def build_sponsor(**attributes)
    Sponsor.new({ name: "Nueva Empresa S.A.S.", kind: :company, nit: "811045673-2", phone: "3001234567", email: "contacto@nueva.example" }.merge(attributes))
  end

  test "is valid with a NIT that passes the DIAN check digit" do
    assert build_sponsor.valid?
    assert_not build_sponsor(nit: "811045673-3").valid?
  end

  test "normalizes NIT separators, phone formatting and email case" do
    sponsor = build_sponsor(nit: "811.045.673-2", phone: "+57 (300) 123-4567", email: " Contacto@Nueva.Example ")

    assert_equal "811045673-2", sponsor.nit
    assert_equal "3001234567", sponsor.phone
    assert_equal "contacto@nueva.example", sponsor.email
  end

  test "accepts mobiles and 60X landlines of the 2021 numbering plan only" do
    assert build_sponsor(phone: "6015551234").valid?
    assert_not build_sponsor(phone: "5551234").valid?
    assert_not build_sponsor(phone: "2015551234").valid?
  end

  test "NIT is unique" do
    assert_not build_sponsor(nit: sponsors(:andina).nit).valid?
  end

  test "cannot be destroyed while it has sponsorships" do
    assert_not sponsors(:andina).destroy
    assert sponsors(:agua).destroy
  end

  test "committed amount adds up its sponsorships" do
    assert_equal 120_000_000, sponsors(:andina).committed_amount
  end
end
