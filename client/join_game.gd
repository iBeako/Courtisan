extends Node

@onready var vbox = %VBoxContainer  # Assurez-vous que c'est bien le conteneur parent
@onready var refresh_button = %Refresh  # Le bouton pour rafraîchir

var lobby_count = 0  # Simule des lobbys différents

func _ready():
	refresh_button.pressed.connect(_on_refresh_pressed)

func _on_refresh_pressed():
	# Simuler de nouveaux lobbys (ex : récupérer depuis un serveur)
	var lobbies = [
		{"name": "Lobby " + str(lobby_count + 1), "creator": "Player " + str(lobby_count + 1)},
		{"name": "Lobby " + str(lobby_count + 2), "creator": "Player " + str(lobby_count + 2)}
	]
	lobby_count += 2  # Pour éviter d'ajouter toujours les mêmes

	# Supprimer les anciens lobbys avant d'ajouter les nouveaux (optionnel)
	for child in vbox.get_children():
		child.queue_free()

	# Ajouter les nouveaux lobbys
	for lobby in lobbies:
		var lobby_instance = load("res://LigneLobby.tscn").instantiate()
		lobby_instance.set_lobby_data(lobby["name"], lobby["creator"])
		vbox.add_child(lobby_instance)
