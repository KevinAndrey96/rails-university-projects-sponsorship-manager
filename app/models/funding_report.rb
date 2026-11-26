require "csv"

# CSV export of the funding status of a set of projects, ready to open in a spreadsheet.
class FundingReport
  HEADERS = %w[proyecto estado tutor presupuesto comprometido faltante porcentaje_financiado patrocinadores].freeze

  def initialize(projects)
    @projects = projects
  end

  def to_csv
    sponsor_names = Sponsorship.joins(:sponsor).where(project_id: @projects.map(&:id))
      .pluck(:project_id, "sponsors.name").group_by(&:first).transform_values { |rows| rows.map(&:last).sort }

    CSV.generate(headers: HEADERS, write_headers: true) do |csv|
      @projects.each do |project|
        csv << [
          project.title,
          I18n.t("projects.statuses.#{project.status}"),
          project.tutor&.name,
          project.budget,
          project.funded_amount,
          project.remaining_amount,
          (project.funding_ratio * 100).round(1),
          sponsor_names.fetch(project.id, []).join("; ")
        ]
      end
    end
  end
end
