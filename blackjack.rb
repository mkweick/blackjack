CARD_VALUES = { "A" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6,
                "7" => 7, "8" => 8, "9" => 9, "10" => 10, "J" => 10, "Q" => 10,
                "K" => 10 }
SUITS = ["\u2660", "\u2663", "\u2665", "\u2666"]

def get_num_decks
  puts "How many decks do you want to play with? (minimum of 3)"
  num_decks = gets.chomp.to_i
  while num_decks < 3 do
    puts "Minimum number of decks is 3"
    num_decks = gets.chomp.to_i
  end
  num_decks
end

def build_deck(num_decks)
  cards = []
  SUITS.each do |suit|
    (2..10).to_a.each do |card|
      cards << { suit: suit, card: card, count: num_decks }
    end
    %w(J Q K A).each do |card|
      cards << { suit: suit, card: card, count: num_decks }
    end
  end
  cards
end

def get_first_two_cards(game_cards)
  first_two_cards = []
  while first_two_cards.count < 2 do
      available_cards = []
      game_cards.each { |values|  available_cards << values if values[:count] > 0 }
      card = get_random_card(available_cards)
      first_two_cards << card
      remove_card_from_deck(game_cards, card)
  end
  first_two_cards
end

def get_random_card(available_cards)
  card_dealt = available_cards.sample
  card = card_dealt[:card], card_dealt[:suit]
  card
end

def remove_card_from_deck(game_cards, card)
  game_cards.each do |values|
    if values[:card] == card[0] && values[:suit] == card[1]
      values[:count] -= 1
    end
  end
end

def print_game(dealer_cards, player_cards, user_name, dealer_turn = 0)
  system 'clear'
  puts " " * 6 + "DEALER"
  puts "-" * 15
  if dealer_turn == 1
    dealer_cards.each do |card|
      puts " " * 7 + card[0].to_s + " " + card[1]
    end
    puts "Total: " + get_total(dealer_cards).to_s
  else
    puts " " * 7 + "???"
    puts " " * 7 + dealer_cards[1][0].to_s + " " + dealer_cards[1][1]
  end
  puts
  puts " " * 6 + user_name.upcase
  puts "-" * (user_name.length + 10)
  player_cards.each do |card|
    puts " " * 7 + card[0].to_s + " " + card[1]
  end
  puts "Total: " + get_total(player_cards).to_s
  puts
end

def get_total(cards)
  total = 0
  cards.each do |values|
    if values[0].to_s == "A" && total < 11
      total += 11
    else
      CARD_VALUES.each do |k, v|
        total += v if values[0].to_s == k
      end
    end
  end
  total
end

def check_blackjack(dealer_cards, player_cards, user_name)
  player_total = get_total(player_cards)
  dealer_total = get_total(dealer_cards)
  if player_total == 21
    if dealer_total == 21
      print_game(dealer_cards, player_cards, name, dealer_turn = 1)
      puts "Push! You and the dealer both hit Blackjack."
      player_total && dealer_total
    else
      print_game(dealer_cards, player_cards, user_name, dealer_turn = 1)
      puts "Blackjack! #{user_name} Wins!"
      player_total
    end
  end
end

def finish_player_hand(game_cards, dealer_cards, player_cards, user_name)
  player_hand = player_cards
  hit_or_stay = hit_or_stay?(user_name)
  while hit_or_stay == "H" do
    player_hand = get_next_card(game_cards, player_hand)
    print_game(dealer_cards, player_hand, user_name)
    break if get_total(player_hand) > 20
    hit_or_stay = hit_or_stay?(user_name)
  end
  if get_total(player_hand) > 21
    puts "#{user_name}, you busted. Dealer wins."
    nil
  else
    player_hand
  end
end

def finish_dealer_hand(game_cards, dealer_cards, player_cards, user_name)
  print_game(dealer_cards, player_cards, user_name, dealer_turn = 1)
  dealer_hand = dealer_cards
  total = get_total(dealer_hand)
  while total < 17 do
    dealer_hand = get_next_card(game_cards, dealer_hand)
    total = get_total(dealer_hand)
    print_game(dealer_hand, player_cards, user_name, dealer_turn = 1)
  end
  if get_total(dealer_hand) > 21
    puts "Dealer Busted. You Win #{user_name}!"
    nil
  else
    dealer_hand
  end
end

def hit_or_stay?(user_name)
  puts "#{user_name}, Hit or Stay? (H/S)"
  hit_or_stay = gets.chomp.upcase
end

def get_next_card(game_cards, cards)
  hand = cards
  available_cards = []
  game_cards.each { |values|  available_cards << values if values[:count] > 0 }
  card = get_random_card(available_cards)
  hand << card
  remove_card_from_deck(game_cards, card)
  hand
end

def check_winner(dealer_cards, player_cards, user_name)
  dealer_total = get_total(dealer_cards)
  player_total = get_total(player_cards)
  if player_total == dealer_total
    puts "It's a tie. You and the dealer both have #{player_total}"
  elsif player_total > dealer_total
    puts "#{user_name} has #{player_total}"
    puts "Dealer has #{dealer_total}"
    puts "#{user_name} Wins!"
  else
    puts "Dealer has #{dealer_total}"
    puts "#{user_name} has #{player_total}"
    puts "Dealer wins."
  end
  nil
end

def reshuffle?(game_cards_left, num_decks)
  total = 0
  game_cards_left.each do |values|
    total += values[:count]
  end
  if total < 21
    shuffle_animation(num_decks)
    total
  else
    nil
  end
end

def shuffle_animation(num_decks)
  puts "Shuffling and stacking #{num_decks.to_s} decks....."
  5.times do |number|
    print "......."
    sleep 1
  end
end

def deal_again?
  puts "Deal again? (Y/N)"
  gets.chomp.upcase
end


def play_blackjack
  puts "Welcome to Blackjack partner! What's your name cowboy?"
  user_name = gets.chomp.capitalize
  num_decks = get_num_decks

  game_cards = build_deck(num_decks)
  shuffle_animation(num_decks)
  begin
    loop do
      game_cards = build_deck(num_decks) if reshuffle?(game_cards, num_decks)
      dealer_cards = get_first_two_cards(game_cards)
      player_cards = get_first_two_cards(game_cards)
      print_game(dealer_cards, player_cards, user_name)
      break if check_blackjack(dealer_cards, player_cards, user_name)
      player_cards = finish_player_hand(game_cards, dealer_cards, player_cards, user_name)
      break if player_cards.nil?
      dealer_cards = finish_dealer_hand(game_cards, dealer_cards, player_cards, user_name)
      break if dealer_cards.nil?
      break if check_winner(dealer_cards, player_cards, user_name).nil?
    end
  end until deal_again? == "N"
end

play_blackjack