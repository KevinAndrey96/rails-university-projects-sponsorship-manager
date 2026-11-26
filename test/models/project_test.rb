require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires a unique title, a summary and a positive budget" do
    project = Project.new(title: projects(:coffee).title.upcase, summary: "", budget: 0)

    assert_not project.valid?
    assert project.errors.added?(:title, :taken, value: projects(:coffee).title.upcase)
    assert project.errors.added?(:summary, :blank)
    assert project.errors.added?(:budget, :greater_than, value: 0, count: 0)
  end

  test "titles are unique regardless of accents and case" do
    assert_not Project.new(title: "DETECCION DE ROYA EN CAFETALES CON VISION POR COMPUTADOR", summary: "x", budget: 1).valid?
  end

  test "rejects unknown statuses" do
    project = projects(:gardens)
    project.status = "abandoned"

    assert_not project.valid?
  end

  test "funding figures come from its sponsorships" do
    project = projects(:landslides)

    assert_equal 150_000_000, project.funded_amount
    assert_equal 30_000_000, project.remaining_amount
    assert_in_delta 0.8333, project.funding_ratio, 0.0001
    assert_not project.fully_funded?
  end

  test "with_funding computes the funded total in a single query" do
    funded = Project.with_funding.index_by(&:id)

    assert_equal 150_000_000, funded[projects(:landslides).id].funded_amount
    assert_equal 0, funded[projects(:gardens).id].funded_amount
  end

  test "over funded projects have no remaining amount" do
    projects(:gardens).sponsorships.create!(sponsor: sponsors(:agua), amount: 50_000_000, committed_on: Date.new(2026, 5, 1))

    assert projects(:gardens).fully_funded?
    assert_equal 0, projects(:gardens).remaining_amount
  end

  test "destroying a project removes its lead and sponsorships but keeps the sponsors" do
    assert_difference "Sponsorship.count" => -2, "StudentLead.count" => -1, "Sponsor.count" => 0 do
      projects(:landslides).destroy
    end
  end

  test "broadcasts a page refresh when a sponsorship changes its funding" do
    assert_turbo_stream_broadcasts projects(:gardens) do
      perform_enqueued_jobs do
        projects(:gardens).sponsorships.create!(sponsor: sponsors(:agua), amount: 10_000_000, committed_on: Date.new(2026, 5, 1))
      end
    end
  end
end
