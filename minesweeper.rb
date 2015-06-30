require 'colorize'
require_relative 'board'
require 'yaml'

class Game
  attr_accessor :board, :next_pos, :next_mark, :player_quit

  def initialize
    @board = Board.new
    @game_over = false
    @next_pos = nil
    @next_mark = nil
    @player_quit = false
  end

  def game_over
     board.won? || board.lost?
  end

  def play
    puts
    puts "WELCOME TO MINESWEEPER".colorize(:blue)
    board.render
    until player_quit || game_over
      puts "player quit - " + player_quit.to_s
      prompt
      make_mark
      board.render
    end
  end

  def prompt
    puts("Give me a row and col e.g. '0,1', '2,3'")
    self.next_pos = gets.chomp.split(",").map(&:to_i)
    puts "Reveal, flag, unflag or quit? R,F,U,Q"
    self.next_mark = gets.chomp.downcase
    if self.next_mark == "q"
      save_and_quit
      return
    end
    unless (valid_pos? && valid_mark?)
      prompt
    end
  end

  def on_board?
    on_board = self.next_pos.all? {|coord| coord.between?(0, 8)}
    puts "Position not on board" unless on_board
    on_board
  end

  def valid_input_pos?
    valid_input = (self.next_pos.is_a? Array) && (self.next_pos.length == 2)
    puts "Not valid" unless valid_input
    valid_input
  end

  def valid_pos?
    on_board? && valid_input_pos?
  end

  def valid_f
    if board[*next_pos].revealed?
      puts "You can't flag a tile that's already been revealed. It's stupid"
      return false
    end
    true
  end

  def valid_u
    unless board[*next_pos].flagged?
      puts "You can only unflag tiles that have been flagged"
      return false
    end
    true
  end

  def valid_r
    if board[*next_pos].revealed?
      puts "That tile has already been revealed!"
      return false
    elsif board[*next_pos].flagged?
      puts "You can't reveal a tile that's been flagged. Unflag first"
      return false
    end
    true
  end

  def valid_letter?
    if ! ["u", "r", "f", "q"].include?(self.next_mark)
      puts "Not a valid character. Must be U, R or F"
      return false
    end
    true
  end

  def save_and_quit
    puts "Are you sure you want to save and quit? Y or N"
    y_or_n = gets.chomp.downcase
    if y_or_n == "y"
      self.player_quit = true
      puts "Okay. We'll save your game. What do you want to name it"
      file_name = gets.chomp
      game_yaml = self.to_yaml
      saved_file = File.open(file_name, "w") {|f| f.write(game_yaml)}
      puts "Bye!"
    end
  end

  def valid_mark?
    if self.next_mark == 'r'
      valid_r
    elsif self.next_mark == 'u'
      valid_u
    elsif self.next_mark == 'f'
      valid_f
    else
      valid_letter?
    end
  end

  def make_mark
    # case next_mark
    # when "r"
    # when "f"
    if next_mark == "r"
      board.reveal(*next_pos)
    elsif next_mark == "f"
      board.flag(*next_pos)
    elsif next_mark == "u"
      board.unflag(*next_pos)
    end
  end


end
