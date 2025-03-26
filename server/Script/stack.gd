extends Node

var card_number: int
var card_played_count = 0

var all_cards = []
var card_stack = []


var player_white_missions = []
var player_blue_missions = []

var global = preload("res://Script/global.gd").new()

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	self.card_number = 0

func _set_card_number(player_max: int) -> void:
	if player_max == 2 :
		card_number = 6
	elif player_max == 3 :
		card_number = 72
	elif player_max == 4 :
		card_number = 84
	elif player_max == 5 :
		card_number = 90
	else :
		print("Error : number of player invalid")

func _get_card_number():
	return card_stack.size()

func print_stack_state() -> void:
	print("	Card stack number : ", card_number)
	print("	Card stack :", card_stack, "\n")
	
func generate_card() -> bool :
	# 90 times
	for family in global.families :
		for card_type_number in global.card_type_numbers :
			for i in range(card_type_number) :
				all_cards.append([i, family])
	
	return !all_cards.is_empty()
	
func _set_card_stack() -> void:
	all_cards.shuffle()
	card_stack = all_cards.slice(0, card_number)
	
func _retrieve_three_cards() -> Array:
	var three_cards = []
	for i in range(3):
		three_cards.append(card_stack.pop_front())
	return three_cards
	
func check_card(card_type: int, family: String) -> bool :
	var card = [card_type, family]
	if all_cards.find(card) != -1 :
		return  true
	return false
	
func _retrieve_card(card_type: int, family: String) -> bool :
	var card = [card_type, family]
	var id = all_cards.find(card)
	if  id != -1 :
		all_cards.remove_at(id)
		return true
	return false

func _get_rand_missions() -> Array:
	var id_white_mission = randi() % global.white_missions.size()
	while player_white_missions.find(id_white_mission) != -1 :
		id_white_mission = randi() % global.white_missions.size()
	player_white_missions.append(id_white_mission)
	
	var id_blue_mission = randi() % global.blue_missions.size()
	while player_blue_missions.find(id_blue_mission) != -1 :
		id_blue_mission = randi() % global.blue_missions.size()
	player_blue_missions.append(id_blue_mission)

	return [id_white_mission, id_blue_mission]
	
func _one_card_played() -> void:
	card_played_count += 1
	
func _no_more_card_to_play() -> bool :
	return card_played_count == card_number
	
func _no_more_card_in_stack() -> bool:
	return card_stack.size() == 0
