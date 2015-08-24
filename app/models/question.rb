class Question < ActiveRecord::Base
  has_many :answers
  serialize :words, Array
end