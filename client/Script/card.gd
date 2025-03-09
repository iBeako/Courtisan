extends Node2D
class_name Card

signal hovered
signal hovered_off

var starting_position
var card_type
var card_color

@onready var sprite = $Sprite2D  # Référence au sprite de la carte

const CARD_TEXTURES = {
	"Papillons": preload("res://Assets/papillons/cropped_card_3.png"),
	"Crapauds": preload("res://Assets/crapauds/cropped_card_4.png"),
	"Rossignols": preload("res://Assets/rossignols/cropped_card_3.png"),
	"Lièvres": preload("res://Assets/lièvres/cropped_card_3.png"),
	"Cerfs": preload("res://Assets/cerfs/cropped_card_4.png"),
	"Carpes": preload("res://Assets/carpes/blue_normal_carte.jpg")
}
func apply_card_texture() -> void:
	var sprite = $CardImage  # Accès au Sprite2D correct
	
	print("→ Assignation de la texture pour:", "'" + card_type + "'")  # Vérification
	if card_type in CARD_TEXTURES:
		sprite.texture = CARD_TEXTURES[card_type]
		sprite.scale = Vector2(0.113, 0.09)  # Applique le scale ici ✅
	else:
		print("⚠ Erreur : texture non trouvée pour '" + card_type + "'")  # Débogage amélioré
func _ready() -> void:
	$Area2D.collision_layer = 1<<3
	get_parent().connect_card_signals(self)
	apply_card_texture()


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
