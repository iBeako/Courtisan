extends Control
const TYPES = preload("res://Script/card.gd").TYPES
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



func _on_button_pressed() -> void:
	# Preload the card scene (as you've done)
	var card_scene = preload("res://Scene/card.tscn")
	
	# Create an instance of the card scene
	var card_instance = card_scene.instantiate()
	card_instance.custom_minimum_size = Vector2(150, 200)
	card_instance.card_color="Papillons"
	card_instance.card_type = Card.TYPES.Normal
	$Panel/MarginContainer2/ScrollContainer/GridContainer.add_child(card_instance)
	
