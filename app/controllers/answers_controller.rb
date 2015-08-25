class AnswersController < ApplicationController
  def create
    @question = Question.find(params[:question_id])

    @answer = @question.answers.build(answer_params)
    @tr = @answer.body.tr('?','')
    @answer.words = @tr.split(' ')

    if @answer.save
      redirect_to questions_path
    else
      render :new
    end
  end

  private

  def answer_params
    params.require(:answer).permit!
  end
end