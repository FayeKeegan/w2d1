require 'byebug'
require 'colorize'

class Tile
  attr_accessor :pos, :flagged
  attr_reader :count, :neighbors, :board, :revealed

  def initialize(pos, board, bomb=false)
    @pos = pos
    @flagged = false
    @revealed = false
    @bomb = bomb
    @board = board
    @neighbors = nil
    @count = nil
  end

  def reveal
    find_neighbors
    return nil if self.revealed? || self.flagged?
    @revealed = true
    return nil if (bomb? || count > 0)
    neighbors.each do |neighbor|
      neighbor.reveal
    end
  end

  def find_neighbors
    neighbor_tiles = []
    matrix = [[0,1],[0,-1],[1,0],[-1,0],[-1,1],[1,-1],[1,1],[-1,-1]]
    matrix.each do |move|
      neighbor_pos = [pos[0] + move[0] , pos[1] + move[1]]
      neighbor_tiles << board[*neighbor_pos] if on_board?(neighbor_pos)
    end
    @neighbors = neighbor_tiles
    count_neighbors
    neighbors
  end

  def count_neighbors
    count = 0
    neighbors.each do |tile|
      count += 1 if tile.bomb?
    end
    count
    @count = count
  end

  def to_s
    if revealed? && bomb?
      "X"
    elsif revealed? && !flagged?
      count > 0 ? count.to_s.colorize(:blue) : "_"
    elsif flagged?
      "F".colorize(:red)
    else
      "?"
    end
  end

  def on_board?(pos) # move to Board class
    pos.all? { |coord| coord.between?(0, 8) }
  end

  def set_as_bomb
    @bomb = true
  end

  def inspect
    {:pos => pos,:bomb => bomb,:revealed => revealed}.inspect
  end

  def bomb?
    @bomb
  end

  def revealed?
    self.revealed
  end

  def flag
    self.flagged = true
  end

  def unflag
    self.flagged = false
  end

  def flagged?
    self.flagged
  end
end
