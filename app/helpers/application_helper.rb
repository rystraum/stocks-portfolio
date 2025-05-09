# frozen_string_literal: true

module ApplicationHelper
  def active_tab?(path)
    return 'active' if request.path == path

    ''
  end

  def company_industry_options
    [
      'Real Estate',
      'Finance',
      'Holding',
      'Preferred',
      'Services',
      'Industrial',
      'Telecom',
      'Media',
      'Capital Goods',
      'Materials',
      'Utilities'
    ]
  end

  def format_currency(amount, places = 2)
    number_to_currency amount, unit: '', precision: places
  end

  def format_percentage(numerator, denominator, precision = 1)
    return '-' if denominator.nil? || denominator.zero?

    number_to_percentage (numerator * 100 / denominator), precision: precision, format: '%n%'
  end

  def green_red(amount)
    tag.span format_currency(amount), class: (amount.negative? ? 'text-red-500' : 'text-green-500').to_s
  end

  def green_red_percent(amount, denominator)
    tag.span format_percentage(amount, denominator), class: (amount.negative? ? 'text-red-500' : 'text-green-500').to_s
  end

  def green_red_percent_badge(amount, denominator)
    tag.span format_percentage(amount, denominator),
             class: (amount.negative? ? 'badge badge-soft-danger' : 'badge badge-soft-success').to_s
  end

  def format_date(date)
    return '-' if date.blank?

    tag.span date.to_formatted_s(:rfc822).upcase, style: 'font-family: monospace'
  end

  def buy_or_not(target_buy_price, current_price)
    return '' if target_buy_price.blank?

    tag.span target_buy_price, class: (current_price < target_buy_price ? 'text-green-500' : 'text-red-500').to_s
  end
end
