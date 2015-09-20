# Used to determine winner and calculate educated computer moves
WINNING_LINES = [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [1,5,9],
                 [3,5,7]]

# Initialize game board values
def new_game_board
    positions = { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 
                  7 => 7, 8 => 8, 9 => 9 }
    positions
end

# Ask player which character to use
def get_player_letter
  puts "Would you like to be X's or O's? (X/O)"
  letter = ""
  loop do
    letter = gets.chomp.upcase
    break if ["X", "O"].include?(letter)
    puts "You can only select 'X' or 'O' as valid game pieces"
  end
  letter
end

# Draw game board to screen with interop hash values (from new_game_board)
def build_board(board)
  puts "     |     |     "
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}   "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}  "
  puts "     |     |     "
end

# Get player move
def player_move(board, letter)
  player_input = valid_tile?(board)
  board[player_input] = letter
end

# Check to see if player move is valid with helpful re-prompt messages and inputs
def valid_tile?(board)
  puts "Specify the number on the board to begin:"
  player_input = gets.chomp.to_i
  loop do
    tile_valid = tile_in_one_thru_nine?(player_input)
    unplayed_tile = tile_already_played?(board, player_input)
    # Only break if both methods above are true
    break if tile_valid && unplayed_tile
    puts "Tile #{player_input} is not between 1-9 or has already been played."
    puts "Please enter a valid tile number:"
    player_input = gets.chomp.to_i
  end
    player_input
end

# Check to verify player has selected a tile between 1-9
def tile_in_one_thru_nine?(tile)
  if (1..9).none? { |number| number == tile }
    return false
  else
    return true
  end
end

# Check to verify selected tile has not been played already
def tile_already_played?(board, tile)
  if board[tile] == "X" || board[tile] == "O"
    return false
  else
    return true
  end
end

# Calculate educated computer move
def computer_move(board, player_letter, computer_letter)
  # Check for 2 values of computer character in same row
  if WINNING_LINES.any? { |two| board.values_at(*two).count(computer_letter) == 2 }
    check_for_computer_two_in_row(board, player_letter, computer_letter)
  # Check for 2 values of player character in same row
  elsif WINNING_LINES.any? { |two| board.values_at(*two).count(player_letter) == 2 }
    check_for_player_two_in_row(board, player_letter, computer_letter)
  # Computer picks random tile
  else
    assign_random_computer_tile(board, computer_letter)
  end
end

# check to see if computer can win, then move to win game
def check_for_computer_two_in_row(board, player_letter, computer_letter)
  # Select rows with 2 computer characters
  two_in_row = WINNING_LINES.select do |two| 
    board.values_at(*two).count(computer_letter) == 2
  end
  # From selected rows above, filter only rows where third tile doesn't contain player letter
  two_in_row_open = two_in_row.select do |two| 
    two.none? do |number| 
      board.values_at(number).include?(player_letter)
    end
  end
  # Rows selected are already blocked by player, run possible player win method
  if two_in_row_open.empty?
    check_for_player_two_in_row(board, player_letter, computer_letter)
  # Block player row with 2 in a row
  else
    # If multiple rows found, select the first row only
    two_in_row_final = two_in_row_open.first
    # From final selected row, select only the tile # that contains an integer
    comp_tile_number = two_in_row_final.select { |tile| (1..9).include?(board[tile]) }
    # Pull-out the tile # from array format to integer
    computer_input = comp_tile_number.first
    # Return board hash key and value
    board[computer_input] = computer_letter
  end
end

#check to see if player can win, then move to possibly prevent player win
def check_for_player_two_in_row(board, player_letter, computer_letter)
  # Select rows with 2 player characters
  two_in_row = WINNING_LINES.select do |two| 
    board.values_at(*two).count(player_letter) == 2
  end
  # From selected rows above, filter only rows where third tile doesn't contain computer letter
  two_in_row_open = two_in_row.select do |two| 
    two.none? do |number| 
      board.values_at(number).include?(computer_letter)
    end
  end
  # Rows selected are already blocked by computer, go for random tile
  if two_in_row_open.empty?
    assign_random_computer_tile(board, computer_letter)
  # Block player row with 2 in a row
  else
    # If multiple rows found, select the first row only
    two_in_row_final = two_in_row_open.first
    # From final selected row, select only the tile # that contains an integer
    comp_tile_number = two_in_row_final.select { |tile| (1..9).include?(board[tile]) }
    # Pull-out the tile # from array format to integer
    computer_input = comp_tile_number.first
    # Return board hash key and value
    board[computer_input] = computer_letter
  end
end

# Generate a random available tile for computer
def assign_random_computer_tile(board, computer_letter)
  computer_input = board.select { |k, v| (1..9).include?(v) }.keys.sample
  board[computer_input] = computer_letter
end

# Check to see if all tiles have been played
def all_tiles_played?(board)
  if board.values.any? { |number| (1..9).include?(number) }
    return false
  else
    return true
  end
end

# Check for winner, return correct winner name
def check_winner(board, player_letter, computer_letter, user_name)
  WINNING_LINES.each do |line|
    return user_name if board.values_at(*line).count(player_letter) == 3
    return "Computer" if board.values_at(*line).count(computer_letter) == 3
  end
  nil
end

# Display winner name
def announce_winner(winner)
  puts "#{winner} won!"
end

puts "Welcome to Tic, Tac, Toe!"
puts "What is your name?"
user_name = gets.chomp.capitalize

# Start Game Loop
loop do
  player_letter = get_player_letter
  # Assign computer opposite letter of player
  player_letter == "X" ? computer_letter = "O" : computer_letter = "X"
  puts "#{user_name}, you will be #{player_letter}'s."
  puts
  board = new_game_board
  build_board(board)
  puts
  puts "You have first move!"
  
  begin
    player_move(board, player_letter)
    build_board(board)
    winner = check_winner(board, player_letter, computer_letter, user_name)
    puts
    # Only allow computer to play if open tiles are left or player didn't win
    if !all_tiles_played?(board) && winner == nil
      puts "Computer is thinking......"
      puts
      sleep 3.0
      computer_move(board, player_letter, computer_letter)
      build_board(board)
      winner = check_winner(board, player_letter, computer_letter, user_name)
      # Announce computer as the winner
      if winner != nil
        announce_winner(winner)
      end
      puts
    # Announce user_name (player) as the winner
    elsif winner != nil
      announce_winner(winner)
    # Declare a tie game, no winner and all tiles played
    else
      puts "It's a tie."
      puts
    end
  # Only end if game board is full or someone has won
  end until all_tiles_played?(board) || winner != nil

  # Check to see if user want to play again
  begin
    puts "Do you want to play again? (Y/N)"
    play_again = gets.chomp.upcase
  end until ["Y", "N"].any? { |letter| letter == play_again }
  break if play_again == "N"

end