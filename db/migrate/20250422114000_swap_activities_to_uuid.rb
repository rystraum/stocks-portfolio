class SwapActivitiesToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys (none found for activities)
    # Step 5: Rename new table to old table name
    drop_table :activities
    rename_table :activities_new, :activities
    # Step 10: Re-add foreign keys (if any were dropped, none in this case)
  end

  def down
    rename_table :activities, :activities_new
    # Note: restoring the old table is not implemented here for safety
  end
end
