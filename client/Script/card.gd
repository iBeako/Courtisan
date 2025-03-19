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

var card_colors = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  

var back_texture = preload("res://Assets/dos_carte.jpg")


# Function to apply the correct texture based on the card's color
func apply_card_texture() -> void:
	#print("→ Assigning texture for:", "'" + card_color + "'")  # Debugging output
	var card_texture : Texture = load("res://Assets/"+card_color.to_lower()+"/"+TYPES.find_key(card_type).to_lower()+".png")
	
	if card_texture!=null:
		sprite.texture = card_texture  # Set the correct texture
	else:
		print("⚠ Error: Texture not found for '" + card_color + "'")  # Error handling
		print("res://Assets/"+card_color.to_lower()+"/"+TYPES.find_key(card_type).to_lower()+".png")
		

func get_value():
	return 2 if card_type == TYPES.Noble else 1

# Function to hide the card (show the back texture)
func hide_card() -> void:
	sprite.texture = back_texture

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
