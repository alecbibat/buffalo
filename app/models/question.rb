class Question < ActiveRecord::Base
  validates :body, uniqueness: true
  serialize :words, Array
end