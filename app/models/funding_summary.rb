# Portfolio wide funding figures for the projects dashboard.
class FundingSummary
  def projects_count
    @projects_count ||= Project.count
  end

  def total_budget
    @total_budget ||= Project.sum(:budget)
  end

  def committed_amount
    @committed_amount ||= Sponsorship.sum(:amount)
  end

  def funding_ratio
    total_budget.zero? ? 0.0 : committed_amount.fdiv(total_budget)
  end

  def fully_funded_count
    @fully_funded_count ||= Project.where(
      id: Project.left_joins(:sponsorships).group(:id).having("COALESCE(SUM(sponsorships.amount), 0) >= projects.budget").select(:id)
    ).count
  end

  def sponsors_count
    @sponsors_count ||= Sponsor.count
  end
end
