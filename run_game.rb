require_relative "player"
require_relative "game"
 
def separate_by_dash
  puts "\n------------------------------------------------------------\n\n"
end

def get_players #amila mala promjena
  available_colors = ['Red', 'Green', 'Blue', 'Yellow']
  players = []

  print "Enter the number of players (2-4): "
  num_players = gets.chomp.to_i

  unless num_players.between?(2, 4)
    puts "Invalid number of players. Please enter a number between 2 and 4."
    separate_by_dash
    return get_players
  end

  (1..num_players).each do |i|
    print "Enter Player #{i}'s name: "
    name = gets.chomp

    puts "Available colors: #{available_colors.join(', ')}"
    print "Choose a color for #{name}: "
    chosen_color = gets.chomp.capitalize

    while !available_colors.map(&:downcase).include?(chosen_color.downcase)
      puts "Invalid color choice or color already chosen. Please choose an available color."
      separate_by_dash
      puts "Available colors: #{available_colors.join(', ')}"
      print "Choose a new color for #{name}: "
      chosen_color = gets.chomp.capitalize
    end

    available_colors.delete_if { |color| color.downcase == chosen_color.downcase }
    player = Player.new(name)
    player.color = chosen_color
    players << player
  end
  players
end

def initial_dice_throws(players)
  players.each_with_index do |player, index|
    puts "#{player.name}, it's your turn to roll the dice. Press Enter to roll."
    gets  # Wait for player input
    3.times do
      dice_value = rand(1..6)
      puts "#{player.name} rolled a #{dice_value}"
      return index if dice_value == 6
    end
  end
  puts "No player rolled a 6. Selecting a random player to start."
  rand(0...players.length)
end

#aldijana
def player_choice_prompt(player)
  puts "#{player.name}, choose your action:"
  puts "1. Move a piece"
  puts "2. Bring a piece out of the house"
  print "Enter your choice (1 or 2): "
  gets.chomp.to_i
end


def select_piece_to_move(player)
  puts "#{player.name}, select a piece to move (enter piece number 1-4):"
  gets.chomp.to_i - 1  # Convert to 0-based index
end


def move_piece(player, symbol, steps) #amila
  pieces_on_board = player.pieces.reject(&:is_at_home)

  if pieces_on_board.empty?
    puts "No pieces on the board to move."
    return
  end

  piece_to_move = pieces_on_board.find { |piece| piece.symbol == symbol }

  if piece_to_move.nil?
    puts "Invalid piece symbol."
    return
  end

  puts "#{player.name}, moving #{piece_to_move.symbol} forward by #{steps} steps."

  begin
    piece_to_move.move_forward(steps)
  rescue StandardError => e
    puts "Error: #{e.message}. Please try again."
  end
end


def bring_piece_out(player)
  piece_at_home = player.pieces.find(&:is_at_home)

  if piece_at_home.nil?
    puts "No pieces at home to bring out."
    return
  end
  move_piece_to_start(player, piece_at_home)
end


def move_piece_forward(player, piece)
  puts "#{player.name}, enter the number of steps to move #{piece.name} forward:"
  steps = gets.chomp.to_i

  begin
    player.move_pieces_based_on_roll(steps)
  rescue StandardError => e
    puts "Error: #{e.message}. Please try again."
    move_piece_forward(player, piece)
  end
end


def move_piece_to_start(player, piece)
  player.move_pieces_based_on_roll(6)
end

#aldijana - modifikovano 
def run_game
  players = get_players
  separate_by_dash

  #aldijana - logic for loading the game
  puts "Do you want to start a new game or load a saved game? (new/load)"
  choice = gets.chomp.downcase

  if choice == 'new'
    starting_player_index = initial_dice_throws(players)
    game = Game.new(true, *players)
    game.start_game_with_player(starting_player_index)
  elsif choice == 'load'
    print "Enter the file path to the saved game: "
    file_path = gets.chomp
    game = Game.new  # Create an instance of Game
    game.load_game(file_path)  # Call the instance method
  else
    puts "Invalid choice. Exiting."
    return
  end

  winner = nil

  #novo - aldijana
  turns_limit = 10  # Limit the game to 10 turns
  turns_since_last_save_prompt = 0

  save_prompt_interval = 2  # Prompt user to save every 2 turns, this can change  
  turns_since_last_save_prompt = 0

  while winner.nil? && game.is_live  && game.total_no_of_turns < turns_limit
    game.display_turn_info

    player = game.current_player_in_game
    puts "#{player.name} it's your turn -"
    puts "\nInstructions:"
    puts "Press enter key to roll the dice."
    puts "Enter 'exit' to quit the game"
    puts "You will not get any points if you score 6's 3 times consecutively"

    gets  # Wait for player input to roll the dice
    game.roll_dice

    if game.last_generated_value == 6
      while game.last_generated_value == 6
        choice = player_choice_prompt(player)
        case choice
        when 1
          move_piece(player, game.current_player_in_game.pieces.first.symbol, game.last_generated_value)
        when 2
          bring_piece_out(player)
        else
          puts "Invalid choice. Please enter 1 or 2."
        end
        game.roll_dice
      end
    else
      choice = player_choice_prompt(player)
      case choice
      when 1
        move_piece(player, game.current_player_in_game.pieces.first.symbol, game.last_generated_value)
      when 2
        bring_piece_out(player)
      else
        puts "Invalid choice. Please enter 1 or 2."
      end
    end

    winner = game.get_winner

    #saving game logic - aldijana
    if game.is_live && (game.total_no_of_turns % 2).zero?  # Check every 2 turns
      puts "Do you want to save the game? (y/n)"
      save_choice = gets.chomp.downcase

      if save_choice == 'y'
        game.save_game
        puts "Game saved successfully to save_game.yaml"
        
        puts "Do you want to continue playing or exit the game? (continue/exit)"
        continue_choice = gets.chomp.downcase
        break if continue_choice == 'exit'
      end
      turns_since_last_save_prompt = 0  # Reset the counter after prompting
    end
  end
  puts "Thank you for playing!"

  # Determine the winner
  winner = game.get_winner
  if winner
    puts "CONCLUSION: #{winner.name} is the winner!"
  else
    puts "CONCLUSION:The game ended in a draw."
  end
end

    
#aldijana
def prompt_save_game
  puts "Do you want to save the game? (y/n)"
  choice = gets.chomp.downcase
  choice == 'y'
end


#ALDIJANA NOVO
def handle_consecutive_sixes(player, game)
  while game.last_generated_value == 6
    choice = player_choice_prompt(player)
    case choice
    when 1
      move_piece(player, game.current_player_in_game.pieces.first.symbol, game.last_generated_value)
    when 2
      bring_piece_out(player)
    else
      puts "Invalid choice. Please enter 1 or 2."
    end
    game.roll_dice
  end
end

def handle_regular_turn(player, game)
  choice = player_choice_prompt(player)
  case choice
  when 1
    move_piece(player, game.current_player_in_game.pieces.first.symbol, game.last_generated_value)
  when 2
    bring_piece_out(player)
  else
    puts "Invalid choice. Please enter 1 or 2."
  end
end



run_game
