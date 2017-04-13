class CreateLogins < ActiveRecord::Migration[5.0]
  def change
    create_table :logins do |t|
      t.string :service
      t.string :ticket
      t.string :username

      t.timestamps
    end
  end
end
