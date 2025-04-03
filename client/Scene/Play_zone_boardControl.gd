extends Control
# Référence à votre nœud PauseMenu
enum PlayZoneType {Grace, Disgrace }
var param_button : Button
@onready var slotMenu : Control = get_node("/root/Main/slotMenuCanvas/SlotMenu")  # Chemin absolu vers SlotMenu
# Fonction appelée au démarrage de la scène
func _ready() -> void:
	# Récupérer les nœuds nécessaires dans la scène
	slotMenu = $"../../slotMenuCanvas/SlotMenu"
	param_button = $Button  # Accède au bouton ParamButton
	
	# Connecter le signal 'pressed' du bouton Param
	param_button.pressed.connect(self._on_param_button_pressed)
	
	# Initialement, on cache le menu de pause
	#slotMenu.visible = false

# Fonction appelée lorsque le bouton Param est pressé
func _on_param_button_pressed() -> void:
	# Inverse la visibilité du menu de pause
	slotMenu.pause()
	slotMenu.instantiate_all_cards(determine_zone_type())

# Function to determine the type of play zone
func determine_zone_type() -> PlayZoneType:
	return get_parent().Play_ZoneType  # Get the play zone type from the parent node
