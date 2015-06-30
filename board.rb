require_relative 'tile'

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(9) { Array.new(9) }
    # @rows = @grid
    populate
    place_bombs
  end

  def rows
    @grid
  end

  def [](row, col)
    self.grid[row][col]
  end

  def []=(row, col, tile)
    self.grid[row, col] = tile
  end

  def reveal(row, col)
    self[row,col].reveal
  end

  def flag(row, col)
    self[row, col].flag
  end

  def unflag(row, col)
    self[row,col].unflag
  end

  def populate
    (0...9).each do |row|
      (0...9).each do |col|
        grid[row][col] = Tile.new([row, col], self)
      end
    end
  end

  def place_bomb
    # @grid.flatten.compact.sample(10)
    place_pos = [(0...9).to_a.sample, (0...9).to_a.sample]
    if self[*place_pos].bomb?
      place_bomb
    else
      self[*place_pos].set_as_bomb
    end
  end

  def place_bombs
    10.times do
      place_bomb
    end
  end

  def render
    puts "  " + (0...9).to_a.join(" ")
    rows.each_with_index do |row, i|
      print_row = [i]
      row.each do |tile|
        print_row << tile.to_s
      end
      puts print_row.join(" ")
    end
    nil
  end

  def lost?
    self.grid.flatten.any? {|tile| tile.bomb? && tile.revealed?}
  end

  def won?
    self.grid.flatten.all? { |tile| tile.flagged? || tile.revealed? }
  end

  def tiles
    self.grid.flatten
  end
end
