# frozen_string_literal: true

json.array! @cash_dividends, partial: "cash_dividends/cash_dividend", as: :cash_dividend
