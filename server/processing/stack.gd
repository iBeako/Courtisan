extends Node

var card_number: int

var all_cards = []
var card_stack = []
var card_type_numbers = [4, 4, 2, 2, 3] # [idle, noble, spy, guard, assassin]

var card_types = ["normal", "noble", "spy", "guard", "assassin"]
var families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	self.card_number = 0

func _set_card_number(player_max: int) -> void:
	if player_max == 2 :
		card_number = 60
	elif player_max == 3 :
		card_number = 72
	elif player_max == 4 :
		card_number = 83
	elif player_max == 5 :
		card_number = 90
	else :
		print("Error : number of players invalid")

func _get_card_number():
	return card_stack.size()

func print_stack_state() -> void:
	print("	Card number : ", card_number)
	print("	Stack :", card_stack)
	
func generate_card() -> bool :
	# 90 times
	for family in families :
		for card_type_number in card_type_numbers :
			for i in range(card_type_number) :
				all_cards.append([card_types[i], family])
	
	return !all_cards.is_empty()
	
func _set_card_stack() -> void:
	all_cards.shuffle()
	card_stack = all_cards.slice(0, card_number)
	
func _retrieve_three_cards() -> Array:
	var three_cards = []
	for i in range(3):
		three_cards.append(card_stack.pop_front())
	return three_cards
	
func check_card(card_type: String, family: String) -> bool :
	var card = [card_type, family]
	if all_cards.find(card) != -1 :
		return  true
	return false
	
func _retrieve_card(card_type: String, family: String) -> bool :
	var card = [card_type, family]
	var id = all_cards.find(card)
	if  id != -1 :
		all_cards.remove_at(id)
		return true
	return false
