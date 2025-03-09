extends Control

@onready var menu = load("res://Scene/menu_principal.tscn")


func _on_retour_menu_pressed() -> void:
	print(menu)
	get_tree().change_scene_to_packed(menu)
