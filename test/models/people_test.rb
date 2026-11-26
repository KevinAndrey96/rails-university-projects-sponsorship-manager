require "test_helper"

class PeopleTest < ActiveSupport::TestCase
  test "tutors need a unique, well formed email" do
    assert_not Tutor.new(name: "Otra", faculty: "Ingeniería", email: "DROJAS@universidad.example").valid?
    assert_not Tutor.new(name: "Otra", faculty: "Ingeniería", email: "sin-arroba").valid?
    assert Tutor.new(name: "Otra", faculty: "Ingeniería", email: "otra@universidad.example").valid?
  end

  test "deleting a tutor leaves its projects without tutor" do
    tutors(:diana).destroy

    assert_nil projects(:landslides).reload.tutor
  end

  test "student leads study between first and twelfth semester" do
    lead = projects(:gardens).build_student_lead(name: "Ana", program: "Agronomía", semester: 13, email: "ana@estudiantes.example")

    assert_not lead.valid?
    assert lead.errors.added?(:semester, :in, value: 13, count: 1..12)
  end

  test "a project has a single student lead" do
    lead = StudentLead.new(project: projects(:landslides), name: "Otro", program: "Sistemas", semester: 5, email: "otro@estudiantes.example")

    assert_not lead.valid?
    assert lead.errors.added?(:project, :taken, value: projects(:landslides))
  end

  test "a sponsor backs a project once with a positive amount" do
    duplicate = projects(:landslides).sponsorships.build(sponsor: sponsors(:andina), amount: 1, committed_on: Date.new(2026, 1, 1))
    zero = projects(:gardens).sponsorships.build(sponsor: sponsors(:agua), amount: 0, committed_on: Date.new(2026, 1, 1))

    assert_not duplicate.valid?
    assert_not zero.valid?
  end
end
