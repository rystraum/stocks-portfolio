# frozen_string_literal: true

module ApplicationHelper
  def format_currency(amount)
    number_to_currency amount, unit: ''
  end

  def format_percentage(numerator, denominator)
    return '-' if denominator.zero?

    number_to_percentage numerator * 100 / denominator, precision: 2, format: '%n %'
  end

  def green_red(amount)
    tag.span format_currency(amount), class: (amount.negative? ? 'text-red' : 'text-green').to_s
  end

  def green_red_percent(amount, denominator)
    tag.span format_percentage(amount, denominator), class: (amount.negative? ? 'text-red' : 'text-green').to_s
  end
end
