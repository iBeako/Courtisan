extends Control

@onready var game = preload("res://Scene/menu_principal.tscn")
@onready var score_line = preload("res://Scene/fin_partie_ligne.tscn")


var players = [
	{"name": "Alice", "profile_id": 1, "score": 125},
	{"name": "Bob", "profile_id": 2, "score": -90},
	{"name": "Charlie", "profile_id": 3, "score": -200},
	{"name": "Diana", "profile_id": 4, "score": 125},
	{"name": "Eve", "profile_id": 5, "score": 60}
]

func _on_play_again_button_down() -> void:
	get_tree().change_scene_to_packed(game)

func _ready():
	# Tri des joueurs par score décroissant
	players.sort_custom(_sort_by_score)

	var last_score = null
	var actual_rank := 0
	var display_rank := 0

	for i in range(players.size()):
		var player = players[i]
		
		if player["score"] != last_score:
			actual_rank = i + 1
			last_score = player["score"]
		
		display_rank = actual_rank
		init_line(display_rank, player["name"], player["profile_id"], player["score"])


func _sort_by_score(a, b):
	return b["score"] < a["score"]

func init_line(rank : int, name : String, pp : int, score : int) -> void: #initialise une ligne dans le tableau des scores
	var ligne = score_line.instantiate()
	ligne.find_child("Place").text = ("👑 " if rank == 1 else "") + str(rank) + ("er" if rank == 1 else "ème")
	ligne.find_child("Name").text = name
	ligne.find_child("TextureRect").texture = load(Global.profile_pictures[pp])
	ligne.find_child("Score").text = str(score)
	
	
	$PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(ligne)
