# frozen_string_literal: true

class CryptoActivityImportItem < ApplicationRecord
  belongs_to :crypto_activity_import
  belongs_to :crypto_currency, optional: true
  belongs_to :duplicate_crypto_activity, class_name: "CryptoActivity", optional: true

  enum :activity_type, { buy: 0, sell: 1 }
  enum :resolution, { pending: 0, accept: 1, ignore: 2 }
end
