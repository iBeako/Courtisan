extends Control

var paused : bool = false
var pause_scene : PackedScene = load("res://Scene/pause_menu.tscn")

# Fonction appelée au démarrage de la scène
func _ready() -> void:
	# Connecter le signal 'pressed' du bouton Settings
	var button_settings = $Settings  # Remplacez 'Settings' par le nom réel de votre bouton dans l'UI
	button_settings.pressed.connect(self._on_settings_button_pressed)  # Connecter le signal 'pressed'
func _on_settings_button_pressed() -> void:
	# Charge la scène menu_principal.tscn
	get_tree().change_scene_to_packed(pause_scene)
