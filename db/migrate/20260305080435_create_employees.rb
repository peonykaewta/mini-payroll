class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :position
      t.decimal :base_salary

      t.timestamps
    end
  end
end
