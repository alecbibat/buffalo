class CreateQuestion < ActiveRecord::Migration
  def change
    create_table :questions do |t|
    	t.timestamps
    	t.text :body
    end
  end
end
