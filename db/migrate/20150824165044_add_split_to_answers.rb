class AddSplitToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :words, :string
  end
end
