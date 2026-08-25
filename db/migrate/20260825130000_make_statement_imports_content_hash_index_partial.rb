# frozen_string_literal: true

class MakeStatementImportsContentHashIndexPartial < ActiveRecord::Migration[7.2]
  def change
    remove_index :statement_imports, %i[user_id content_hash]
    # status 3 = failed; failed imports must not block re-uploading the same file.
    add_index :statement_imports, %i[user_id content_hash], unique: true, where: "status != 3"
  end
end
