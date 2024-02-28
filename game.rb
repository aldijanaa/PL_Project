require_relative "player"
require "securerandom"
require 'yaml'
 
class Game
  attr_reader :players, :game_id
  attr_accessor :is_live
  @@total_score = 100

  def initialize(is_live = true, *players)
    @is_live = is_live
    @players = players
    @game_id = SecureRandom.uuid
    @current_player = 0
    @total_no_of_turns = 0
    @last_generated_value = 0
    @current_player_name = ""
    @no_of_sixes = 0
    @board = Board.new #amila
    @board_size = Board::BOARD_SIZE #amila
    @house_positions = Board::HOUSE_POSITIONS #amila
    # @board = initialize_board
    # @board = create_board #amila

    players.each do |player|
      player.game_id = @game_id
      player.pieces ||= Array.new(4) { |i| Piece.new("p#{i + 1}") } # Added new line
      set_starting_position(player)
    end  #amila
  end

  def find_piece_at_position(row, col)
    @players.each do |player|
      player.pieces.each do |piece|
        return piece if piece.position == row * board_size + col
      end
    end
    nil
  end
    # Place players in their home positions
    # / HOUSE_POSITIONS.each do |color, (row, col)|
    #   player = players.find { |p| p.color.downcase == color.to_s }
    #    initialize_player_pieces(player)
    # player.pieces.each_with_index do |piece, piece_index|
    #   piece.position = row * BOARD_SIZE + col
    #end / amila ali neka je iskomentirano ovo hahahah
    #
    @dice_rolls_first_turn = Hash.new(0)

  def start_game_with_player(starting_player_index)
    @current_player = starting_player_index
    @current_player_name = @players[starting_player_index].name  #amila
  end

  def initialize_player_pieces(player) #amila
    #player.pieces ||= Array.new(4) { Piece.new }
    player.pieces ||= Array.new(4) { |i| Piece.new("p#{i + 1}") } # Added new line

  end

  def set_starting_position(player)
    start_position = @house_positions[player.color.downcase.to_sym] #amila ovo samo house i board iz initialize
    player.pieces.each_with_index do |piece, piece_index|
      piece.position = start_position[0] * @board_size + start_position[1] + piece_index
    end
  end

  def first_turn?
    @total_no_of_turns < @players.length
  end  #amila

  def move_piece_to_start(player) #amila
    # Implement the logic to move a piece to the start position based on the player's color
    # You can use HOUSE_POSITIONS to find the start position
    start_position = @house_positions[player.color.downcase.to_sym]
    player.pieces.first.position = start_position[0] * @board_size + start_position[1]
  end

  def separate_by_dash
    puts "\n--------------------------LUDO GAME----------------------------\n\n"
  end

  #aldijana
  def total_no_of_turns
    @total_no_of_turns
  end

=begin def create_board #amila
    empty_cell = '◯'
    player_red = %w[r1 r2 r3 r4]
    player_green = %w[g1 g2 g3 g4]
    player_yellow = %w[y1 y2 y3 y4]
    player_blue = %w[b1 b2 b3 b4]
    #player_cells = ['R', 'G', 'Y', 'B']
    safehouse_cell = '●'
    start_cell = '*'
    nil_cell = nil

    board = Array.new(21) { Array.new(21, ' ') }

    # Initialize start positions for each player
    board[8][0] = start_cell
    board[20][8] = start_cell
    board[12][20] = start_cell
    board[0][12] = start_cell

    # red player
    #[18].each { |row| [18,20].each { |col| board[row][col] = player_red[0,1] } }
    #[20].each { |row| [18,20].each { |col| board[row][col] = player_red[2,3] } }
    [18, 20].each { |row| [18,20].each { |col| board[row][col] = player_red.shift } }

    # green player
    [0, 2].each { |row| [18,20].each { |col| board[row][col] = player_green.shift } }

    # blue player
    [18, 20].each { |row| [0,2].each { |col| board[row][col] = player_blue.shift } }

    # yellow player
    [0,2].each { |row| [0,2].each { |col| board[row][col] = player_yellow.shift } }


    # Initialize start positions for each player
    board[8][0] = start_cell
    board[20][8] = start_cell
    board[12][20] = start_cell
    board[0][12] = start_cell

    # Initialize safehouses for each player
    #red
    [10].each { |row| [12, 14, 16, 18].each { |col| board[row][col] = safehouse_cell } }

    #yellow
    [10].each { |row| [2, 4, 6, 8].each { |col| board[row][col] = safehouse_cell } }

    #green
    [2, 4, 6, 8].each { |row| [10].each { |col| board[row][col] = safehouse_cell } }

    #blue
    [12, 14, 16, 18].each { |row| [10].each { |col| board[row][col] = safehouse_cell } }


    # Set specified cells to empty_cells

    [8].each { |row| [0, 2, 4, 6, 8].each { |col| board[row][col] = empty_cell } }
    [6, 4, 2, 0].each { |row| [8].each { |col| board[row][col] = empty_cell } }
    [0].each { |row| [10, 12].each { |col| board[row][col] = empty_cell } }
    [2, 4, 6, 8].each { |row| [12].each { |col| board[row][col] = empty_cell } }
    [8].each { |row| [14, 16, 18, 20].each { |col| board[row][col] = empty_cell } }
    [10, 12].each { |row| [20].each { |col| board[row][col] = empty_cell } }
    [12].each { |row| [12, 14, 16, 18].each { |col| board[row][col] = empty_cell } }
    [14, 16, 18, 20].each { |row| [12].each { |col| board[row][col] = empty_cell } }
    [20].each { |row| [8, 10].each { |col| board[row][col] = empty_cell } }
    [12, 14, 16, 18].each { |row| [8].each { |col| board[row][col] = empty_cell } }
    [12].each { |row| [0, 2, 4, 6].each { |col| board[row][col] = empty_cell } }
    [10].each { |row| [0].each { |col| board[row][col] = empty_cell } }


    return board
  end

  def [](row, col) #amila
    @board[row][col]
  end
=end

  def find_piece_position(piece) #amila
    translated_piece = translate_piece_name(piece)

    @board.each_with_index do |row, row_index|
      row.each_with_index do |cell, col_index|
        return [row_index, col_index] if cell == translated_piece
      end
    end

    nil  # Return nil if the piece is not found on the board
  end

  def translate_piece_name(piece) #amila
    color, number = piece.match(/([a-zA-Z]+)(\d+)/).captures
    "#{color.downcase}#{number}"
  end


  def instructions
    @current_player_name = @players[@current_player].name
    puts "#{players[@current_player].name} it's your turn -" if (@last_generated_value != 6)
    puts "\nInstructions: "
    puts "Press enter key to roll the dice."
    puts "Enter 'exit' to quit the game"
    puts "You will not get any points if you score 6's 3 times consecutively\n\n"
  end

  def will_continue? #mala promjena- amila
    return false unless @is_live

    instructions
    print "Press enter to roll the dice or enter 'exit' to quit: "
    player_input = gets.chomp.downcase

    case player_input
    when ""
      true
    when "exit"
      @is_live = false
      false
    else
      puts "Please enter a valid input!"
      will_continue?
    end
  end



  def handle_turns
    if @last_generated_value == 6
      @no_of_sixes += 1
      if @no_of_sixes < 3
        puts "\n\nHurray...!!!\n#{@current_player_name}, you have got one more chance!"
        roll_dice
      else
        puts "\n\nOops...!!!\n#{@current_player_name}, you have scored 3 consecutive 6's."
        puts "As per the rule, no points will be added for these 3 turns."
        @no_of_sixes = 0
        next_player
      end
    else
      @no_of_sixes = 0
      next_player
      will_continue?
    end
  end


  def next_player
    @total_no_of_turns += 1
    next_player_index = @total_no_of_turns % @players.length
    @current_player = next_player_index
    @current_player_name = @players[next_player_index].name
  end

  def increment_score
    score = @players[@current_player].score + @last_generated_value
    if (score <= @@total_score)
      @players[@current_player].score = score
    end
  end

  def get_winner
    winner = @players.select { |player| player.score == @@total_score }[0]
    if winner
      puts "#{winner.name} won the game!!!\n\n"
      @is_live = false
    end
    return winner
  end

#aldijana update
  def roll_dice
    @last_generated_value = rand(1..6)

    puts "#{@current_player_name} rolled a #{@last_generated_value}"

    if @last_generated_value == 6
      @no_of_sixes += 1
      if @no_of_sixes < 3
        puts "\n\nHurray...!!!\n#{@current_player_name}, you have got one more chance!"
        move_pieces_based_on_roll(@last_generated_value)
        roll_dice
        @board.display_board_state
      else
        puts "\n\nOops...!!!\n#{@current_player_name}, you have scored 3 consecutive 6's."
        puts "As per the rule, no points will be added for these 3 turns."
        @no_of_sixes = 0
        next_player
      end
    else
      @no_of_sixes = 0
      move_pieces_based_on_roll(@last_generated_value)
      handle_turns
    end
  end



  
def handle_first_turn(player)
  return unless first_turn?

  puts "\n#{player.name}, it's your first turn. Press Enter to roll the dice."
  gets

  first_roll = roll_dice(player)
  puts "#{player.name} rolled a #{first_roll}"

  if first_roll == 6
    puts "#{player.name}, you rolled a 6 and will start the game!"
    piece_out = bring_out_any_piece(player)
    puts "#{player.name}, Pawn #{piece_out.symbol[-1]} out of the house."
  else
    puts "#{player.name}, you rolled a #{first_roll}"

    if player.pieces.any?(&:is_at_home)
      piece_out = bring_out_any_piece(player)
      puts "#{player.name}, Pawn #{piece_out.symbol[-1]} out of the house."
    else
      puts "#{player.name}, no pawns available to move out."
    end

    second_roll = roll_dice(player)
    puts "#{player.name} rolled a #{second_roll}"
    #move_piece_on_board(player, piece_out, second_roll) if piece_out
    if piece_out
      move_piece_on_board(player, piece_out, second_roll)
    else
      puts "#{player.name}, no pawns available to move."
    end
    
  end

  @dice_rolls_first_turn[player] += 1
  next_player
end

  
  
  
  
  
  

  def check_winning_conditions #amila
    current_player = @players[@current_player]

    if current_player.pieces.all? { |piece| piece.is_at_home}
      puts "#{current_player.name} won the game!!!"
      @is_live = false
    end
  end

 
=begin def move_pieces_based_on_roll(dice_value) #amila
    current_player = @players[@current_player]
    pieces_outside_home = current_player.pieces.select { |p| !p.is_at_home }

    if pieces_outside_home.any?
      # Logic to choose which piece to move if multiple pieces are outside
      # For simplicity, let's move the first piece in the list
      piece_to_move = pieces_outside_home.first
      piece_to_move.move_forward(dice_value)  # Assuming move_forward method updates the position

      # Move the piece on the board
      move_piece(current_player, piece_to_move.symbol, dice_value)
    else
      # Logic to automatically move a single piece outside
      if dice_value == 6
        # Bring a piece out of home if available
        piece_at_home = current_player.pieces.find { |p| p.is_at_home }
        piece_at_home.leave_home if piece_at_home
      end
    end
  end
=end


#aldijana updated
def move_pieces_based_on_roll(dice_value)
  
  current_player = @players[@current_player]
  pieces_outside_home = current_player.pieces.select { |p| !p.is_at_home }

  if pieces_outside_home.empty?
    # No pieces outside home, bring out any piece
    piece_to_move = bring_out_any_piece(current_player)
  elsif pieces_outside_home.length == 1
    # Only one piece outside home, move it automatically
    piece_to_move = pieces_outside_home.first
    move_piece_on_board(current_player, piece_to_move, dice_value)
  else
    # Multiple pieces outside home, let the player choose which one to move
    piece_to_move = choose_piece_to_move(pieces_outside_home)
    move_piece_on_board(current_player, piece_to_move, dice_value)
  end
end

#aldijana
def bring_out_any_piece(player)
  piece_at_home = player.pieces.find(&:is_at_home)
  if piece_at_home
    piece_at_home.leave_home
    puts "#{player.name}, Piece #{piece_at_home.symbol[-1]} is out of the house."
    return piece_at_home
  end
  nil
end


#aldijana
def choose_piece_to_move(pieces_outside_home)
  puts "Select a piece to move (enter piece number 1-#{pieces_outside_home.length}):"

  pieces_outside_home.each_with_index do |piece, index|
    puts "#{index + 1}. Move #{piece.symbol}"
  end

  choice = nil
  loop do
    print "Enter your choice: "
    choice = gets.chomp.to_i

    if (1..pieces_outside_home.length).cover?(choice)
      return pieces_outside_home[choice - 1]
    else
      puts "Invalid choice. Please enter a number between 1 and #{pieces_outside_home.length}."
    end
  end
end

#aldijana
def player_choice_prompt(player, can_move_piece, pieces_outside_home)
  puts "#{player.name}, choose your action:"
  puts "1. Move a piece" if can_move_piece
  puts "2. Bring a piece out of the house"

  if pieces_outside_home.length == 1
    puts "Currently, only Pawn #{pieces_outside_home.first.symbol} is outside the house."
    puts "Pawn #{pieces_outside_home.first.symbol} moved 5 steps forward."
    return 0
  end

  print "Enter your choice (1 or 2): "
  gets.chomp.to_i
end


#aldijana
def move_piece_on_board(player, piece, dice_value)
  if piece
    # ovaj line nesto neće da radi, jer je symbol initially set to nil
    #puts "#{player.name}, moving #{piece.symbol} (Pawn #{piece.symbol[-1]}) forward by #{dice_value} steps."
    piece.move_forward(dice_value)
  else
    puts "Invalid choice. Please select a piece to move."
  end
end

  def current_player_in_game #amila
    players = @players
    current_player_index = @current_player
    players[current_player_index]
  end


  def last_generated_value
    @last_generated_value
  end


  def display_turn_info #amila
    puts "\nTurn #{ @total_no_of_turns + 1} - Current Player: #{@current_player_name}"
  end



  #Logic for saving the game
  def save_game(file_path = 'save_game.yaml') #amila
    game_state = {
      players: @players.map(&:to_h),
      current_player: @current_player,
      total_no_of_turns: @total_no_of_turns,
      last_generated_value: @last_generated_value,
      no_of_sixes: @no_of_sixes
    }
    File.open(file_path, 'w') { |file| file.write(game_state.to_yaml) }
    puts "Game saved successfully to #{file_path}"
  end

  #Logic for loading the game 
  def load_game(file_path = 'save_game.yaml') #amila
    #loaded_game = YAML.safe_load(File.read(file_path), [Symbol]) amila
    
    #aldijana
    loaded_game = YAML.load(File.read(file_path))

    # Set the loaded game state
    @players = loaded_game[:players].map { |player_info| Player.from_h(player_info) }
    @current_player = loaded_game[:current_player]
    @total_no_of_turns = loaded_game[:total_no_of_turns]
    @last_generated_value = loaded_game[:last_generated_value]
    @no_of_sixes = loaded_game[:no_of_sixes]
    puts "Game loaded successfully from #{file_path}"
  end



end





