extends Button
class_name Card

# Signals emitted when the card is hovered or the hover ends
signal start_drag

var is_hovered : bool = false
var is_draggable : bool = true
var is_dragging : bool = false

var base_scale : Vector2 = Vector2(1,1) #scale de base de la carte (pour la sortie du hover)

# Enum for different card types
enum TYPES {
	Normal,
	Assassin,
	Espion,
	Garde,
	Noble
}

var palette_courtisans = {
	"rossignols": {
		"light": "#CA2D48",  # Rouge clair
		"dark": "#920F29"    # Rouge foncé
	},
	"cerfs": {
		"light": "#177456",  # Vert olive
		"dark": "#133C26"    # Vert foncé
	},
	"carpes": {
		"light": "#4875B1",  # Bleu acier
		"dark": "#3A5977"    # Bleu foncé
	},
	"lièvres": {
		"light": "#F0BC30",  # Or
		"dark": "#D39814"    # Brun doré
	},
	"crapauds": {
		"light": "#8D911F",  # Vert clair
		"dark": "#6A7826"    # Vert forêt
	},
	"papillons": {
		"light": "#B0C5C4",  # Gris clair
		"dark": "#9C9C96"    # Gris foncé
	}
}


# Card properties
var starting_position : Vector2 = Vector2.ZERO
var card_type : TYPES  # Type of the card
@export var card_color : String  # Color/faction of the card
@onready var sprite : TextureRect = $TextureRect  # Reference to the card's sprite
@onready var shadow : ColorRect = $Shadow

var tween_hover : Tween
var tween_rot : Tween

@export var angle_x_max: float = 7.0
@export var angle_y_max: float = 7.0
@export var max_offset_shadow: float = 15.0



# Dictionary storing the textures for different card colors

var card_colors = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  

var back_texture = preload("res://Assets/dos_carte.jpg")

func _process(delta: float) -> void:
	handle_shadow()
	if is_hovered: 
		handle_rot()

#Function to apply the correct texture based on the card's color
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
	apply_card_texture()  # Apply the texture when the card is initialized
	var anim_player = $AnimationPlayer
	anim_player.play("rotate")  # Joue l'animation
	var random_time = randf() * anim_player.current_animation_length  # Temps aléatoire dans l'animation
	anim_player.seek(random_time, true)  # Décale à ce moment
	
	apply_particle_color()


func apply_particle_color():
	var particles = $GPUParticles2D
	if not particles or not particles.process_material:
		return

	if not (card_color.to_lower() in palette_courtisans): 
		return
	
	
	# DUPLIQUER le matériau pour éviter qu’il soit partagé entre toutes les cartes
	particles.process_material = particles.process_material.duplicate()

	var mat : Material = particles.process_material  # Récupérer le matériau unique

	# Création d'un dégradé de couleur
	var gradient = Gradient.new()
	gradient.add_point(0.0, palette_courtisans[card_color.to_lower()]["light"])
	gradient.add_point(1.0, palette_courtisans[card_color.to_lower()]["dark"])

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient

	# Appliquer le dégradé au matériau des particules
	mat.set("color_ramp", gradient_texture)

	# Redémarrer les particules pour voir les changements
	particles.emitting = false
	
	#print(material.get("color_ramp"))


func handle_rot():
	# gere la rotation
	var mouse_pos : Vector2 = get_local_mouse_position()


	var lerp_val_x : float = remap(mouse_pos.x, 0, sprite.size.x, -1, 1)
	var lerp_val_y : float = remap(mouse_pos.y, 0, sprite.size.y, -1, 1)

	# Interpolation correcte de l'angle (sans lerp_angle)
	var rot_x : float = lerp(-angle_x_max, angle_x_max, (lerp_val_x + 1) * 0.5)  # Inclinaison horizontale
	var rot_y : float = lerp(angle_y_max, -angle_y_max, (lerp_val_y + 1) * 0.5)  # Inclinaison verticale

	# Appliquer aux paramètres du shader
	sprite.material.set_shader_parameter("x_rot", rot_y)
	sprite.material.set_shader_parameter("y_rot", rot_x)

func handle_shadow() -> void:
	# Y position is enver changed.
	# Only x changes depending on how far we are from the center of the screen
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))




func _on_mouse_entered() -> void:
	if not is_draggable : return 
	print("entered")
	is_hovered = true
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite, "scale", Vector2(1.05, 1.05), 0.3)
	shadow.scale = Vector2(1.05, 1.05)


func _on_mouse_exited() -> void:
	if is_dragging : return
	is_hovered = false
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(sprite.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(sprite.material, "shader_parameter/y_rot", 0.0, 0.5)
	shadow.scale = base_scale
	
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite, "scale", Vector2.ONE, 0.55)


func dragging(val : bool):
	is_dragging = val
	$GPUParticles2D.emitting = val

func card_placed():
	shadow.visible = false
	is_draggable = false
	$CardPlacedSound.play()
	$AnimationPlayer.stop()
	


func _on_button_down() -> void:
	if is_draggable:
		start_drag.emit(self)
