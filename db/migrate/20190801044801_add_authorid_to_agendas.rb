class AddAuthoridToAgendas < ActiveRecord::Migration[5.2]
  def change
    add_column :agendas, :author_id, :integer, index: true
    add_foreign_key :agendas, :users, column: :author_id
  end
end
