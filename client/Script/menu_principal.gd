extends Control

# ScènesC

@onready var create_lobby = preload("res://Scene/Create_lobby.tscn")
@onready var join_game = preload("res://Scene/Join_game.tscn")
@onready var param = preload("res://Scene/param.tscn")

# Configuration manuelle des pivots (exemple pour Play)
func _ready():
	$VBoxContainer/Play.pivot_offset = Vector2(300, 50)
	$VBoxContainer/Join.pivot_offset = Vector2(300, 50)
	$VBoxContainer/Button.pivot_offset = Vector2(300, 50)
	$VBoxContainer/Rule.pivot_offset = Vector2(300, 50)
	$VBoxContainer/QuitButton.pivot_offset = Vector2(300, 50)

# Fonction d'animation réutilisable
func animate_button(button_path: String, target_scale: Vector2):
	var button = get_node(button_path)
	var tween = create_tween()
	tween.tween_property(button, "scale", target_scale, 0.2)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

# Handlers pour Play
func _on_play_mouse_entered():
	animate_button("VBoxContainer/Play", Vector2(1.1, 1.1))

func _on_play_mouse_exited():
	animate_button("VBoxContainer/Play", Vector2(1, 1))

# Handlers pour Join
func _on_join_mouse_entered():
	animate_button("VBoxContainer/Join", Vector2(1.1, 1.1))

func _on_join_mouse_exited():
	animate_button("VBoxContainer/Join", Vector2(1, 1))

# Handlers pour Button
func _on_button_mouse_entered():
	animate_button("VBoxContainer/Button", Vector2(1.1, 1.1))

func _on_button_mouse_exited():
	animate_button("VBoxContainer/Button", Vector2(1, 1))

# Handlers pour Rule
func _on_rule_mouse_entered():
	animate_button("VBoxContainer/Rule", Vector2(1.1, 1.1))

func _on_rule_mouse_exited():
	animate_button("VBoxContainer/Rule", Vector2(1, 1))

# Handlers pour QuitButton
func _on_quit_button_mouse_entered():
	animate_button("VBoxContainer/QuitButton", Vector2(1.1, 1.1))

func _on_quit_button_mouse_exited():
	animate_button("VBoxContainer/QuitButton", Vector2(1, 1))

# Gestion des clics (conservée comme avant)
func _on_start_button_button_down():
	get_tree().change_scene_to_packed(create_lobby)

func _on_quit_button_button_down():
	get_tree().quit()

func _on_button_button_down():
	get_tree().change_scene_to_packed(param)

func _on_join_button_down():
	get_tree().change_scene_to_packed(join_game)

func _on_rule_button_down():
	pass  # À implémenter si besoin
