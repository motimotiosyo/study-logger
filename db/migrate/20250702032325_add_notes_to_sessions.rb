class AddNotesToSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :sessions, :notes, :text
  end
end
