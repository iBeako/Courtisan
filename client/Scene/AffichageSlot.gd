extends Control

var paused : bool = false

var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")

func _ready() -> void:
	resume()

func resume():
	$AnimationPlayer.play_backwards("blur")
	paused = false
	await $AnimationPlayer.animation_finished
	self.visible = false
	
	
func pause():
	self.visible = true
	$AnimationPlayer.play("blur")
	paused = true

func _on_resume_pressed() -> void:
	resume()

# Fonction pour afficher les cartes dans AffichageSlotCard
func afficher_cartes(cartes: Array) -> void:
	print("Displaying cards...")

	if cartes.size() == 0:
		print("Error: No cards to display")
		return
	
	var card_scene = preload("res://Scene/card.tscn")  # Précharge la scène de la carte

	var i = 0
	# Itérer sur toutes les cartes du slot
	for card in cartes:
		var new_card = card_scene.instantiate()  # Instancier une nouvelle carte

		# Assigner des propriétés spécifiques à la carte
		new_card.card_color = card.card_color  # Par exemple, assigner la couleur
		new_card.card_type = card.card_type    # Par exemple, assigner le type de carte
		
		new_card.z_index = 5  # Définir l'ordre de rendu
		new_card.name = "carte_" + card.card_type  # Donner un nom unique à la carte
		
		# Ajouter la carte à l'AffichageSlotCard
		add_child(new_card)
		
		# Optionnellement, appliquer une texture ou d'autres propriétés spécifiques à chaque carte
		# new_card.apply_card_texture()  # Décommente si nécessaire

		# Positionner la carte (ajuste la position en fonction de l'indice)
		new_card.rect_position = Vector2(0, i * 50)  # Par exemple, espace de 50 pixels entre chaque carte
		i += 1

	print("Cards displayed successfully")
