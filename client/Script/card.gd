extends Node2D
class_name Card

# Signals emitted when the card is hovered or the hover ends
signal hovered
signal hovered_off


var is_hovered : bool = false

# Enum for different card types
enum TYPES {
	Normal,
	Assassin,
	Espion,
	Garde,
	Noble
}

# Card properties
var starting_position : Vector2 = Vector2.ZERO
var card_type : TYPES  # Type of the card
var card_color : String  # Color/faction of the card
@onready var sprite : TextureRect = $TextureRect  # Reference to the card's sprite
@onready var shadow : ColorRect = $Shadow

var tween_hover : Tween
var tween_rot : Tween

@export var angle_x_max: float = 7.0
@export var angle_y_max: float = 7.0
@export var max_offset_shadow: float = 20.0



# Dictionary storing the textures for different card colors

var card_colors = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  

var back_texture = preload("res://Assets/dos_carte.jpg")

func _process(delta: float) -> void:
	
	handle_shadow(delta)
	if is_hovered: 
		handle_rot()
	
func handle_rot():
	# gere la rotation
	var mouse_pos : Vector2 = get_local_mouse_position()
	print(mouse_pos)

	var lerp_val_x : float = remap(mouse_pos.x, -sprite.size.x/2, sprite.size.x/2, -1, 1)
	var lerp_val_y : float = remap(mouse_pos.y, -sprite.size.y/2, sprite.size.y/2, -1, 1)

	# Interpolation correcte de l'angle (sans lerp_angle)
	var rot_x : float = lerp(-angle_x_max, angle_x_max, (lerp_val_x + 1) * 0.5)  # Inclinaison horizontale
	var rot_y : float = lerp(angle_y_max, -angle_y_max, (lerp_val_y + 1) * 0.5)  # Inclinaison verticale

	# Appliquer aux paramètres du shader
	sprite.material.set_shader_parameter("x_rot", rot_y)
	sprite.material.set_shader_parameter("y_rot", rot_x)

# Function to apply the correct texture based on the card's color
func apply_card_texture() -> void:
	#print("→ Assigning texture for:", "'" + card_color + "'")  # Debugging output
	var card_texture : Texture = load("res://Assets/"+card_color.to_lower()+"/"+TYPES.find_key(card_type).to_lower()+".png")
	
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = preload("res://Assets/Shaders/fake_3d.gdshader")

	sprite.material = shader_mat #shader permettant un faux effet de 3D
	#shadow.material = shader_mat
	
	#shadow.material.set_shader_parameter("rect_size", shadow.size)
	sprite.material.set_shader_parameter("rect_size", sprite.size)
	
	
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
	is_hovered = true
	emit_signal("hovered", self)
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite, "scale", Vector2(1.05, 1.05), 0.3)

# Signal function: triggers when the mouse exits the card's area
func _on_area_2d_mouse_exited() -> void:
	is_hovered = false
	emit_signal("hovered_off", self)
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(sprite.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(sprite.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite, "scale", Vector2.ONE, 0.55)


func handle_shadow(delta: float) -> void:
	# Y position is enver changed.
	# Only x changes depending on how far we are from the center of the screen
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x))) - shadow.size.x/2
