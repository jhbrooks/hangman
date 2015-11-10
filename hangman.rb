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
    @commands = [:save, :load, :guess]
  end

  def start
    load_words
    winnow_words
    state.target_word = select_word
    state.letter_update_match_string
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
    puts
    state.display(line_width)
    ask_for_input
    if state.win?
      win
    elsif state.lose?
      lose
    else
      take_turn
    end
  end

  def ask_for_input
    puts "Valid commands: #{commands.join(', ')}"
    puts "Please guess a letter, or enter a command."
    input = gets.chomp!
    if input.length == 1
      human_letter(input)
    else
      human_command(input)
    end
  end

  def human_letter(input)
    if guessed?(input)
      puts "You've already guessed that letter! Please try again.\n\n"
      ask_for_input
    elsif !letter?(input)
      puts "That's not a letter! Please try again.\n\n"
      ask_for_input
    else
      state.last_guess = input
      state.letters_guessed << input
      state.letter_update_match_string
      state.letter_update_guesses_left
    end
  end

  def guessed?(input)
    state.letters_guessed.include?(input)
  end

  def letter?(input)
    input.ord.between?("a".ord, "z".ord)
  end

  def human_command(input)
    if commands.include?(input.to_sym)
      execute_command(input.to_sym)
    else
      puts "That's not a valid command! Please try again.\n\n"
      ask_for_input
    end
  end

  def execute_command(command)
    case command
    when :save then execute_save
    when :load then execute_load
    when :guess then execute_guess
    end
  end

  def execute_save
    puts "Save not yet implemented."
  end

  def execute_load
    puts "Load not yet implemented."
  end

  def execute_guess
    puts "Please guess a word."
    state.last_guess = gets.downcase.chomp!
    state.guess_update_match_string
    state.guess_update_guesses_left
  end

  def win
    puts
    puts "*** Great guessing! You have won! ***".center(line_width)
    puts
    puts "Target word: #{state.target_word}".center(line_width)
    state.display(line_width)
  end

  def lose
    puts
    puts "*** You have lost! Better luck next time! ***".center(line_width)
    puts
    puts "Target word: #{state.target_word}".center(line_width)
    state.display(line_width)
  end

  private

  attr_reader :dict_filename, :state, :min_length, :max_length,
              :line_width, :commands
  attr_accessor :words, :target_word
end

# This class handles game state information
class State
  attr_accessor :target_word, :last_guess, :letters_guessed

  def initialize
    @target_word = ""
    @last_guess = ""
    @letters_guessed = []
    @match_string = ""
    @guesses_left = 5
  end

  def letter_update_match_string
    self.match_string = ""
    target_word.split("").each do |letter|
      if letters_guessed.include?(letter)
        match_string << (letter)
      else
        match_string << "-"
      end
    end
  end

  def guess_update_match_string
    self.match_string = last_guess if target_word == last_guess
  end

  def letter_update_guesses_left
    self.guesses_left -= 1 unless target_word.include?(last_guess)
  end

  def guess_update_guesses_left
    self.guesses_left -= 1 unless target_word == last_guess
  end

  def display(line_width)
    puts "Results: #{match_string}".center(line_width)
    puts "Guesses left: #{guesses_left}".center(line_width)
    puts
    puts "Letters guessed: "\
         "#{letters_guessed.join(', ')}" if letters_guessed.length > 0
  end

  def win?
    target_word == match_string || target_word == last_guess
  end

  def lose?
    guesses_left == 0
  end

  private

  attr_accessor :match_string, :guesses_left
end

g = Game.new
g.start
