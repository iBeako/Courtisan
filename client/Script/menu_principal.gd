extends Control

@onready var game = load("res://Scene/main.tscn")
@onready var param = load("res://Scene/param.tscn")



func _on_start_button_button_down() -> void:
	get_tree().change_scene_to_packed(game)
	


func _on_quit_button_button_down() -> void:
	get_tree().quit()


func _on_button_button_down() -> void:
	print(param)
	
	get_tree().change_scene_to_packed(param)
