require 'securerandom'
 
class Player
  attr_reader :name, :player_id
  attr_accessor :game_id, :score, :color, :pieces

  def initialize(name, score = 0)
    @name = name
    @score = score
    @game_id = nil
    @player_id = SecureRandom.uuid
    @pieces = Array.new(4) { Piece.new }
  end

  # Logic for saving the game - aldijana
  def to_h
    {
    name: @name,
    score: @score,
    game_id: @game_id,
    player_id: @player_id,
    pieces: @pieces.map(&:to_h),
     color: @color
    }
  end

  #aldijana
  def self.from_h(player_info)
    player = new(player_info[:name], player_info[:score])
    player.game_id = player_info[:game_id]
    player.player_id = player_info[:player_id]
    player.pieces = player_info[:pieces].map { |piece_info| Piece.from_h(piece_info) }
    player.color = player_info[:color]
    player
  end

   # aldijana - add setter method for player_id
   def player_id=(id)
    @player_id = id
  end
end

###########################################################################
class Piece
  attr_accessor :position,  :symbol
  SAFEHOUSE_RANGES = {
    red: (8..14),
    green: (1..7),
    blue: (8..14),
    yellow: (1..7)
  }
  def initialize()
    @position = nil
    @symbol = nil
  end

  def is_at_home
    position.nil?
  end

  #Logic for saving the game - aldijana
  def to_h
    {
      position: @position,
      symbol: @symbol
    }
  end

  #aldijana
  def self.from_h(piece_info)
    piece = new
    piece.position = piece_info[:position]
    piece.symbol = piece_info[:symbol]
    piece
  end

  # Logic to set the initial position of the piece when it leaves home
  def leave_home
    self.position = 0  # Example: setting position to 0
  end

  #Logic to move the piece forward by 'steps' positions
  def move_forward(steps)
    new_position = self.position + steps

    # Check if the new position is within the safehouse
    if within_safehouse?(new_position)
      # Handle entering the safehouse
      enter_safehouse
    else
      # Normal movement logic
      self.position = new_position
    end
  end

  def within_safehouse?(position) #amila
    SAFEHOUSE_RANGES.include?(position)
  end

  #Logic to handle entering the safehouse
  def enter_safehouse #amila
    # For simplicity, let's set the position to the middle of the safehouse range
    self.position = SAFEHOUSE_RANGES.middle
  end
end


###############################################################################
class Board #amila, ovo sam ovako dodala jer ne da da napravim board.rb ali nema veze
  BOARD_SIZE = 15
  HOUSE_POSITIONS = {
    red: [1, 1],
    green: [BOARD_SIZE - 2, 1],
    blue: [1, BOARD_SIZE - 2],
    yellow: [BOARD_SIZE - 2, BOARD_SIZE - 2]
  }

  def initialize
    @board = initialize_board
  end

  def display_board_state
    puts "\nCurrent Board State:"
    puts "---------------------"

    @board.each_with_index do |row, row_index|
      row.each_with_index do |cell, col_index|
        print cell.nil? ? '◯' : cell
      end
      puts
    end

    puts "---------------------"
  end

  def initialize_board
    empty_cell = '◯'
    player_symbols = %w[r1 r2 r3 r4 g1 g2 g3 g4 b1 b2 b3 b4 y1 y2 y3 y4]

    board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, nil) }

    HOUSE_POSITIONS.each do |color, (row, col)|
      player_symbols_for_color = player_symbols.shift(4)
      player_symbols_for_color.each_with_index do |symbol, index|
        board[row][col] = player_symbols_for_color[index]
      end
    end

    board
  end

  def find_piece_at_position(row, col)
    @board[row][col]
  end

  def [](row, col)
    @board[row][col]
  end

  def []=(row, col, value)
    @board[row][col] = value
  end

  def size
    @board.size
  end

  def each(&block)
    @board.each(&block)
  end

  def each_with_index(&block)
    @board.each_with_index(&block)
  end
  def make_methods_public #amila
    public_send :each_with_index
  end
end

