class AddDoneToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :done, :boolean, default: false
  end
end
