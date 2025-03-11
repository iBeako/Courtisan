extends Node2D
class_name Card

signal hovered
signal hovered_off

enum TYPES {
	Normal,
	Assassin,
	Espion,
	Garde,
	Noble
}


var starting_position : Vector2
var card_type : TYPES
var card_color : String

var sprite : TextureRect   # Référence au sprite de la carte

const CARD_TEXTURES = {
	"Papillons": preload("res://Assets/papillons/lièvres_normal.png"),
	"Crapauds": preload("res://Assets/crapauds/crapauds_normal.png"),
	"Rossignols": preload("res://Assets/rossignols/rossignols_normal.png"),
	"Lièvres": preload("res://Assets/lièvres/lièvres_normal.png"),
	"Cerfs": preload("res://Assets/cerfs/cerfs_normal.png"),
	"Carpes": preload("res://Assets/carpes/carpe_normal.jpg"),
	"Back": preload("res://Assets/dos_carte.jpg")
}
func apply_card_texture() -> void:
	#var sprite = $CardImage  # Accès au Sprite2D correct
	#print(sprite)
	sprite.texture
	print("→ Assignation de la texture pour:", "'" + card_color + "'")  # Vérification
	if card_color in CARD_TEXTURES:
		sprite.texture = CARD_TEXTURES[card_color]
		
	else:
		print("⚠ Erreur : texture non trouvée pour '" + card_color + "'")  # Débogage amélioré

func hide_card() -> void:
	#var sprite = $CardImage  # Accès au Sprite2D correct
	
	sprite.texture = CARD_TEXTURES["Back"]
	
	
	

func _ready() -> void:
	sprite = $TextureRect
	$Area2D.collision_layer = 1<<3
	get_parent().connect_card_signals(self)
	apply_card_texture()


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
