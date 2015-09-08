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
      proper_nouns = tgr.get_proper_nouns(tagged).to_a
      nouns = tgr.get_nouns(tagged).to_a

      # makes the searched noun 'doge'
      # if there is no noun in the question
      if nouns == []
        @a_noun = "Doge"
      elsif proper_nouns.any?
        @a_noun = proper_nouns.sample.first
      else
        @a_noun = nouns.sample.first
      end

      # search twitter for the noun in question
      @tweets = $twitter.search(@a_noun, result_type: "recent").take(50).collect do |tweet|
        "#{tweet.text}"
      end

      @tweet_words = []
      @tweets.each do |tweet|
        regex = "/[\u{2026}\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E7}-\u{1F1EC}\u{1F1EE}-\u{1F1F0}\u{1F1F3}\u{1F1F5}\u{1F1F7}-\u{1F1FA}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F320}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}]/"
        tweet.tr!(regex, '')
        tweet = tweet.tr('.', '')
        tweet = tweet.tr('?', '')
        tweet = tweet.tr('!', '')
        tweet = tweet.tr(':', '')
        tweet = tweet.tr('"', '')
        tweet = tweet.split(' ')
        @tweet_words << tweet
      end

      @tweet_words.flatten!

      # clean up the tweet words
      @trash = []
      @tweet_words.each do |word|
        word.downcase!
        if word.start_with? 'ht'
          @trash << word
        elsif word.start_with? '@'
          @trash << word
        elsif word.start_with? 'rt'
          @trash << word
        elsif word.start_with? '#'
          @trash << word
        elsif word.start_with? '&'
          @trash << word
        elsif word.start_with? '-'
          @trash << word
        elsif word.start_with? '/'
          @trash << word
        elsif word.start_with? ':'
          @trash << word
        elsif word.start_with? '('
          @trash << word
        elsif word.start_with? ')'
          @trash << word
        elsif word.include? '|'
          @trash << word
        elsif word.start_with? 'af'
          @trash << word
        end
      end

      @tweet_words = @tweet_words - @trash

      # build a sentence

      tgr = EngTagger.new()
      @tweet_words = @tweet_words.join(' ')
      tagged = tgr.add_tags(@tweet_words)
      nouns = tgr.get_nouns(tagged).to_a
      pt_verbs = tgr.get_past_tense_verbs(tagged).to_a
      g_verbs = tgr.get_gerund_verbs(tagged).to_a
      i_verbs = tgr.get_infinitive_verbs(tagged).to_a
      verbs = pt_verbs + g_verbs + i_verbs
      # verbs is an array of arrays
      adj = tgr.get_adjectives(tagged).to_a
      articles = ['the', 'this', 'that', 'those', 'these']
      x_verbs = ['is', 'was', ' will be']
      punctuation = ['.', '!', '...']
      noun_phrases = tgr.get_noun_phrases(tagged).to_a
      conjunctions = ['but', 'and', 'although', 'however']

      # say something profound

      @readable = articles.sample.capitalize + ' ' + 
                  @a_noun + ' ' + 
                  x_verbs.sample + ' ' + 
                  adj.sample.first + ', ' + 
                  conjunctions.sample + 
                  ' the ' + 
                  noun_phrases.sample.first + ' ' + 
                  verbs.sample.first + ' ' + 
                  nouns.sample.first + 
                  punctuation.sample
  render :new
  @question.save
end

  private

  def question_params
    params.require(:question).permit!
  end
end