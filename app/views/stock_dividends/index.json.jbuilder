# frozen_string_literal: true

json.array! @stock_dividends, partial: "stock_dividends/stock_dividend", as: :stock_dividend
