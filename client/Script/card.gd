extends Node2D

signal hovered
signal hovered_off

var starting_position
var card_type  # Type de la carte (blanc, vert, rouge, etc.)
var card_color
const CARD_COLORS = {
	"blanc": Color(1, 1, 1),  # Blanc
	"vert": Color(0, 1, 0),   # Vert
	"rouge": Color(1, 0, 0),  # Rouge
	"jaune": Color(1, 1, 0),  # Jaune
	"marron": Color(0.6, 0.3, 0),  # Marron
	"bleu": Color(0, 0, 1)    # Bleu
}

func _ready() -> void:
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
