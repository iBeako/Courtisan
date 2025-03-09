extends Node2D

signal hovered
signal hovered_off

var starting_position
var card_type
var card_color
const CARD_COLORS = {
	"Papillons": Color(1, 1, 1),  # Blanc
	"Crapauds": Color(0, 1, 0),   # Vert
	"Rossignols": Color(1, 0, 0),  # Rouge
	"Lièvres": Color(1, 1, 0),  # Jaune
	"Cerfs": Color(0.6, 0.3, 0),  # Marron
	"Carpes": Color(0, 0, 1)    # Bleu
}


func _ready() -> void:
	$Area2D.collision_layer = 1<<3
	get_parent().connect_card_signals(self)
	apply_card_color()

# Appliquer la couleur en fonction du type
func apply_card_color():
	if card_type and card_type in CARD_COLORS:
		self.modulate = CARD_COLORS[card_type]  # Change la couleur de la carte

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
