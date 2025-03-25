extends Control

# Load the main game scene
@onready var game = preload("res://Scene/main.tscn")

# Load the parameter/settings scene
@onready var param = preload("res://Scene/param.tscn")

# Function triggered when the Start button is pressed
func _on_start_button_button_down() -> void:
	# Change to the game scene
	get_tree().change_scene_to_packed(game)

# Function triggered when the Quit button is pressed
func _on_quit_button_button_down() -> void:
	# Quit the game
	get_tree().quit()

# Function triggered when another button (presumably for settings) is pressed
func _on_button_button_down() -> void:
	# Print the parameter scene reference (for debugging purposes)
	print(param)
	# Change to the parameter/settings scene
	get_tree().change_scene_to_packed(param)


func _on_play_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($VBoxContainer/Play, "scale", Vector2(1.1,1.1), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _on_play_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($VBoxContainer/Play, "scale", Vector2(1,1), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
