#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

# This class operates the game
class Game
  def initialize
    @dict_filename = "5desk.txt"
    @words = []

    @state = State.new

    @min_length = 5
    @max_length = 12
    @line_width = 80
  end

  def start
    load_words
    winnow_words
    state.target_word = select_word
    state.update_match_string
    take_turn
  end

  def load_words
    dict_file = File.open(dict_filename, "r")
    dict_file.each do |line|
      words << (line.strip)
    end
    dict_file.close
  end

  def winnow_words
    self.words = words.select do |word|
      not_proper?(word) && valid_length?(word)
    end
  end

  def not_proper?(word)
    word[0].ord.between?("a".ord, "z".ord)
  end

  def valid_length?(word)
    word.length >= min_length && word.length <= max_length
  end

  def select_word
    words[rand(words.length)]
  end

  def take_turn
    state.display(line_width)
    ask_for_guess
    if state.win?
      win
    elsif state.lose?
      lose
    else
      take_turn
    end
  end

  def ask_for_guess
    puts "Please guess a letter."
    state.last_guess = human_guess
    state.letters_guessed << (state.last_guess)
    state.update_match_string
    state.update_guesses_left
  end

  def human_guess
    guess = gets.downcase.chomp!
    if guessed?(guess)
      puts "You've already guessed that letter! Please try again."
      human_guess
    elsif !single_letter?(guess)
      puts "That's not a letter! Please try again."
      human_guess
    else
      guess
    end
  end

  def guessed?(guess)
    state.letters_guessed.include?(guess)
  end

  def single_letter?(guess)
    guess.ord.between?("a".ord, "z".ord) && guess.length == 1
  end

  def win
    puts
    puts "*** Great guessing! You have won! ***".center(line_width)
    state.display(line_width)
  end

  def lose
    puts
    puts "*** You have lost! Better luck next time! ***".center(line_width)
    state.display(line_width)
  end

  private

  attr_reader :dict_filename, :state, :min_length, :max_length, :line_width
  attr_accessor :words, :target_word
end

# This class handles game state information
class State
  attr_writer :target_word
  attr_accessor :last_guess, :letters_guessed

  def initialize
    @target_word = ""
    @last_guess = ""
    @letters_guessed = []
    @match_string = ""
    @guesses_left = 5
  end

  def update_match_string
    self.match_string = ""
    target_word.split("").each do |letter|
      if letters_guessed.include?(letter)
        match_string << (letter)
      else
        match_string << "-"
      end
    end
  end

  def update_guesses_left
    self.guesses_left -= 1 unless target_word.include?(last_guess)
  end

  def display(line_width)
    puts
    puts "Results: #{match_string}".center(line_width)
    puts "Guesses left: #{guesses_left}".center(line_width)
    puts
    puts "Letters guessed: "\
         "#{letters_guessed.join(', ')}" if letters_guessed.length > 0
  end

  def win?
    target_word == match_string
  end

  def lose?
    guesses_left == 0
  end

  private

  attr_reader :target_word
  attr_accessor :match_string, :guesses_left
end

g = Game.new
g.start
