class AddSplitToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :words, :string
  end
end
