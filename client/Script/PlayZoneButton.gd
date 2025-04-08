extends Control
# Référence à votre nœud PauseMenu
var param_button : Button
@onready var slotMenu : Control = get_node("../slotMenuCanvas/SlotMenu")
# Fonction appelée au démarrage de la scène
func _ready() -> void:
	# Récupérer les nœuds nécessaires dans la scène
	param_button = $Button  # Accède au bouton ParamButton
	
	# Connecter le signal 'pressed' du bouton Param
	param_button.pressed.connect(self._on_param_button_pressed)
	
	# Initialement, on cache le menu de pause
	slotMenu.visible = false

# Fonction appelée lorsque le bouton Param est pressé
func _on_param_button_pressed() -> void:
	# Inverse la visibilité du menu de pause
	slotMenu.pause()
