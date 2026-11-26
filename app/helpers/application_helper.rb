module ApplicationHelper
  def cop(value)
    number_to_currency(value.to_i, unit: "$", precision: 0, delimiter: ".", format: "%u %n")
  end

  def compact_cop(value)
    amount = value.to_i
    return cop(amount) if amount < 1_000_000

    millions = number_with_precision(amount / 1_000_000.0, precision: 1, delimiter: ".", separator: ",", strip_insignificant_zeros: true)
    t("helpers.money.millions", amount: millions)
  end

  def percentage(ratio)
    number_to_percentage(ratio.to_f * 100, precision: 1, separator: ",", strip_insignificant_zeros: true)
  end

  def status_badge(project)
    tag.span(t("projects.statuses.#{project.status}"), class: "status status-#{project.status}")
  end

  def funding_bar(project)
    render "projects/funding", project: project
  end

  def status_options
    Project.statuses.keys.map { |status| [ t("projects.statuses.#{status}"), status ] }
  end

  def sponsor_kind_options
    Sponsor.kinds.keys.map { |kind| [ t("sponsors.kinds.#{kind}"), kind ] }
  end

  def formatted_phone(phone)
    phone.to_s.sub(/\A(\d{3})(\d{3})(\d{4})\z/, '\1 \2 \3')
  end

  def nav_link(label, path)
    active = current_page?(path)
    link_to label, path, class: ("active" if active), aria: { current: ("page" if active) }
  end
end
