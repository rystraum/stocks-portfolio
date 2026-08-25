# frozen_string_literal: true

class StatementImport < ApplicationRecord
  belongs_to :user
  has_many :statement_import_items, dependent: :destroy

  enum :status, { parsing: 0, reviewing: 1, completed: 2, failed: 3 }
end
