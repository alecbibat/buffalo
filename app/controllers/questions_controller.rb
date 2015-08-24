class QuestionsController < ApplicationController
  def index
    @questions = Question.all

  end

  def new
    @question = Question.new()
  end

  def show
  end

  def create
    @question = Question.new(question_params)
    if @question.save
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def question_params
    params.require(:question).permit!
  end
end