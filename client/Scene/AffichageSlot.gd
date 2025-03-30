extends Control
const TYPES = preload("res://Script/card.gd").TYPES
const CARD_COLORS = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]
var paused : bool = false
var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")

func _ready() -> void:
	resume()
func resume():
	# Supprime toutes les cartes dans le GridContainer
	for card in $Panel/MarginContainer2/ScrollContainer/GridContainer.get_children():
		card.queue_free()  # Supprime proprement chaque carte
	
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



func _on_button_pressed() -> void:
	var random_type = randi() % TYPES.size()  # Choix aléatoire parmi les types
	var random_color = CARD_COLORS[randi() % CARD_COLORS.size()]  # Choix aléatoire parmi les couleurs
	instantiate_card(random_type,random_color)
	
func instantiate_card(card_type: TYPES, card_color: String) -> void:
		# Preload the card scene (as you've done)
	var card_scene = preload("res://Scene/card.tscn")
	
	# Create an instance of the card scene
	var card_instance = card_scene.instantiate()
	card_instance.custom_minimum_size = Vector2(164, 300)
	card_instance.card_color=card_color
	card_instance.card_type = card_type
	$Panel/MarginContainer2/ScrollContainer/GridContainer.add_child(card_instance)
