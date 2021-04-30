class AddUserIdToActivities < ActiveRecord::Migration[6.0]
  def change
    add_reference :activities, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        Activity.update_all(user_id: User.first.id)
      end
    end
  end
end
