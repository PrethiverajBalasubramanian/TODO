class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.text :description
      t.boolean :status, default: false
      t.references :topic, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
