class QuestionsController < ApplicationController
  def index

    @questions = Question.all

  end

  def new
    @answer = @readable
    @question = Question.new()
  end

  def show
    @question = Question.find(params[:id])
    @answer = Answer.new()
  end

  def create
    @question = Question.new(question_params)
    @tr = @question.body.tr('?','')
    @question.words = @tr.split(' ')
    if @question.save
      text = @question.body
      tgr = EngTagger.new()
      tagged = tgr.add_tags(text)
      nouns = tgr.get_nouns(tagged)
      #pt_verbs = tgr.get_past_tense_verbs(tagged)
      #g_verbs = tgr.get_gerund_verbs(tagged)
      #i_verbs = tgr.get_infinitive_verbs(tagged)
      #adj = tgr.get_adjectives(tagged)
      #tr = @question.body.tr('?','')
      #words = tr.split(' ')
      @first_noun = nouns.first
      @answer_words = []
      @questions = Question.all()
        @questions.each do |question|
          if question.words.include? @first_noun.first
            @answer_words << question.words
            question.answers.each do |answer|
              @answer_words << answer.words
            end
            @answer_words = @answer_words.flatten
            @answer_words = @answer_words.uniq
          else
          end
        end
      tgr = EngTagger.new()
      @answer_words = @answer_words.join(' ')
      tagged = tgr.add_tags(@answer_words)
      nouns = tgr.get_nouns(tagged).to_a
      pt_verbs = tgr.get_past_tense_verbs(tagged).to_a
      g_verbs = tgr.get_gerund_verbs(tagged).to_a
      i_verbs = tgr.get_infinitive_verbs(tagged).to_a
      verbs = pt_verbs + g_verbs + i_verbs
      # verbs is an array of arrays
      adj = tgr.get_adjectives(tagged).to_a
      binding.pry
      @readable = nouns.sample.first + ' ' + nouns.sample.first + ' ' + nouns.sample.first
      redirect_to question_answer_path(1, 1, @readable)
    else
      redirect_to 'http://google.com'
    end
  end

  private

  def question_params
    params.require(:question).permit!
  end
end