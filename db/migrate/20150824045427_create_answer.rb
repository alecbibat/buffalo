class CreateAnswer < ActiveRecord::Migration
  def change
    create_table :answers do |t|
    	t.timestamps
    	t.text :body
    end
  end
end
