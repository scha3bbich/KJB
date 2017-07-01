class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.date :date
      t.references :scout, index: true, foreign_key: true
      t.boolean :attending

      t.timestamps null: false
    end
  end
end
