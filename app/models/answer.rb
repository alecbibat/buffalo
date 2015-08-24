class Answer < ActiveRecord::Base
  belongs_to :question
  serialize :words, Array
end