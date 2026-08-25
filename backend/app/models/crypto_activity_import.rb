# frozen_string_literal: true

class CryptoActivityImport < ApplicationRecord
  belongs_to :user
  has_many :import_items, class_name: "CryptoActivityImportItem", dependent: :destroy
  has_many :crypto_activities, dependent: :nullify

  enum :status, { pending: 0, resolving: 1, completed: 2, failed: 3 }

  validates :content_hash, uniqueness: { scope: :user_id, message: "has already been imported" }, allow_nil: true

  def unresolved_duplicates?
    import_items.where.not(duplicate_crypto_activity_id: nil).where(resolution: :pending).any?
  end

  def all_resolved?
    !unresolved_duplicates?
  end
end
