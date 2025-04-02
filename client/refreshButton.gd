extends Control

@onready var button = $Refresh
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var menu = preload("res://Scene/menu_principal.tscn")
@onready var arrow = $TextureButton
var lobby_count = 0  # Compteur pour incrémenter les labels
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().debug_collisions_hint = true  # Visualiser les zones cliquables
	button.pressed.connect(_on_refresh_pressed)
	arrow.pressed.connect(_on_texture_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_refresh_pressed():
	# Instancier la scène LigneLobby
	var scene_to_instance = load("res://Scene/LigneLobby.tscn").instantiate()

	# Ajouter la scène instanciée au ScrollContainer (assure-toi que c'est bien un ScrollContainer)
	$ScrollContainer/VBoxContainer.add_child(scene_to_instance)

	# Accéder aux labels dans la scène instanciée
	var lobby_label = scene_to_instance.get_node("HBoxContainer/LobbyName")
	var creator_label = scene_to_instance.get_node("HBoxContainer/CreatorName")


	# Modifier le texte des labels
	lobby_label.text = "Lobby " + str(lobby_count)  # Exemple de texte dynamique
	creator_label.text = "Creator " + str(lobby_count)  # Exemple de texte dynamique
	lobby_count=lobby_count+1


func _on_texture_button_pressed() -> void:
	print("click on texture button")
	get_tree().change_scene_to_packed(menu)
