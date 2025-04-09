extends Control

@onready var game = preload("res://Scene/menu_principal.tscn")

func _on_play_again_button_down() -> void:
	get_tree().change_scene_to_packed(game)



#extends Control
#
#var ligne = load()
#
##@onready var container = $VBoxContainer
#
## Called when the node enters the scene tree for the first time.
##func _ready() -> void:
	##$VBoxContainer/Label.text = "s"
#
#
##func _on_button_pressed() -> void:
	##print("hello")
#func _ready() -> void:
	#pass # Replace with function body.
#var d = [
	#{"name": "nom",
	#"score" : 0,
	#"id_im":1}
#]
##sort la liste
##instancier les lignes pour chaque joueur
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
