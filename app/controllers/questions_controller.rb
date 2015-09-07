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
      text = @question.body
      tgr = EngTagger.new()
      tagged = tgr.add_tags(text)
      nouns = tgr.get_nouns(tagged).to_a
      if nouns == []
        @a_noun = "Doge"
      else
      @a_noun = nouns.sample.first
    end
      @tweets = $twitter.search(@a_noun, result_type: "recent").take(3).collect do |tweet|
  "#{tweet.text}"
end
      @readable = @tweets.sample
      @readable = @readable.tr('RT', '')
      @readable_split = @readable.split(' ')
      @trash = []
        @readable_split.each do |word|
          if word.start_with? 'ht'
            @trash << word
          elsif word.start_with? '@'
            @trash << word
          elsif word.start_with? '#'
            @trash << word
          end
        end

      @true_readable = @readable_split - @trash
      @readable = @true_readable.join(' ')
      # delete string if start_with? "http", "@" 
      binding.pry
      ####### @first_noun = nouns.sample.first
      # @answer_words = []
      # @questions = Question.all()
      #   @questions.each do |question|
      #     if question.words.include? @first_noun.first
      #       @answer_words << question.words
      #       question.answers.each do |answer|
      #         @answer_words << answer.words
      #       end
      #       @answer_words = @answer_words.flatten
      #       @answer_words = @answer_words.uniq
      #     else
      #     end
      #   end
      # tgr = EngTagger.new()
      # @answer_words = @answer_words.join(' ')
      # tagged = tgr.add_tags(@answer_words)
      # nouns = tgr.get_nouns(tagged).to_a
      # pt_verbs = tgr.get_past_tense_verbs(tagged).to_a
      # g_verbs = tgr.get_gerund_verbs(tagged).to_a
      # i_verbs = tgr.get_infinitive_verbs(tagged).to_a
      # verbs = pt_verbs + g_verbs + i_verbs
      # # verbs is an array of arrays
      # adj = tgr.get_adjectives(tagged).to_a
      # articles = ['the', 'this', 'that', 'those', 'these']
      # x_verbs = ['is', 'was', ' will be']
      # punctuation = ['?', '.', '!', '...']

      # if nouns == []
      #   nouns = [['Doge', 1], ['God', 1], ['poop', 1], ['life', 1]]
      # else
      # end

      # @readable = articles.sample.capitalize + ' ' + nouns.sample.first + ' ' + x_verbs.sample + ' ' + nouns.sample.first + punctuation.sample
      # redirect_to question_answer_path(1, 1, @readable)
  render :new
end

  private

  def question_params
    params.require(:question).permit!
  end
end