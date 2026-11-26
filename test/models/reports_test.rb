require "test_helper"

class ReportsTest < ActiveSupport::TestCase
  test "funding summary aggregates the whole portfolio" do
    projects(:gardens).sponsorships.create!(sponsor: sponsors(:agua), amount: 45_000_000, committed_on: Date.new(2026, 5, 1))
    summary = FundingSummary.new

    assert_equal 3, summary.projects_count
    assert_equal 345_000_000, summary.total_budget
    assert_equal 225_000_000, summary.committed_amount
    assert_equal 1, summary.fully_funded_count
  end

  test "funding report exports one csv row per project with its sponsors" do
    rows = CSV.parse(FundingReport.new(Project.with_funding.includes(:tutor).ordered).to_csv, headers: true)
    landslides = rows.find { |row| row["proyecto"] == projects(:landslides).title }

    assert_equal 3, rows.size
    assert_equal "En curso", landslides["estado"]
    assert_equal "150000000", landslides["comprometido"]
    assert_equal "83.3", landslides["porcentaje_financiado"]
    assert_equal "Andina Tecnología S.A.S.; Secretaría Departamental de Ciencia", landslides["patrocinadores"]
  end

  test "page counts grouped scopes" do
    page = Page.new(Project.with_funding.ordered, number: 2, size: 2)

    assert_equal 3, page.total_count
    assert_equal 2, page.total_pages
    assert_equal 1, page.records.size
    assert_nil page.next_page
  end
end
