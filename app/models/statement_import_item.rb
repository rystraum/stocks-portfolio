# frozen_string_literal: true

class StatementImportItem < ApplicationRecord
  belongs_to :statement_import
  belongs_to :company, optional: true

  enum :item_type, { buy: 0, sell: 1, cash_dividend: 2, redemption: 3, skipped: 4 }
end
