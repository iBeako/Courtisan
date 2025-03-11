extends Node2D
class_name Card

# Signals emitted when the card is hovered or the hover ends
signal hovered
signal hovered_off

# Enum for different card types
enum TYPES {
	Normal,
	Assassin,
	Espion,
	Garde,
	Noble
}

# Card properties
var starting_position : Vector2  # Initial position of the card
var card_type : TYPES  # Type of the card
var card_color : String  # Color/faction of the card
var sprite : TextureRect  # Reference to the card's sprite

# Dictionary storing the textures for different card colors
const CARD_TEXTURES = {
	"Papillons": preload("res://Assets/papillons/cropped_card_3.png"),
	"Crapauds": preload("res://Assets/crapauds/cropped_card_4.png"),
	"Rossignols": preload("res://Assets/rossignols/cropped_card_3.png"),
	"Lièvres": preload("res://Assets/lièvres/cropped_card_3.png"),
	"Cerfs": preload("res://Assets/cerfs/cropped_card_4.png"),
	"Carpes": preload("res://Assets/carpes/blue_normal_carte.jpg"),
	"Back": preload("res://Assets/dos_carte.jpg")  # Back of the card
}

# Function to apply the correct texture based on the card's color
func apply_card_texture() -> void:
	#print("→ Assigning texture for:", "'" + card_color + "'")  # Debugging output
	
	if card_color in CARD_TEXTURES:
		sprite.texture = CARD_TEXTURES[card_color]  # Set the correct texture
	else:
		print("⚠ Error: Texture not found for '" + card_color + "'")  # Error handling

# Function to hide the card (show the back texture)
func hide_card() -> void:
	sprite.texture = CARD_TEXTURES["Back"]

# Ready function: runs when the node is added to the scene
func _ready() -> void:
	sprite = $TextureRect  # Get the TextureRect node
	$Area2D.collision_layer = 1 << 3  # Set the collision layer
	get_parent().connect_card_signals(self)  # Connect hover signals
	apply_card_texture()  # Apply the texture when the card is initialized

# Signal function: triggers when the mouse enters the card's area
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

# Signal function: triggers when the mouse exits the card's area
func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
