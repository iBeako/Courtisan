extends Control
# Référence à votre nœud PauseMenu
var pause_menu : Control
var param_button : Button

# Fonction appelée au démarrage de la scène
func _ready() -> void:
	# Récupérer les nœuds nécessaires dans la scène
	pause_menu = $"../CanvasLayer/PauseMenu"  # Accède au nœud PauseMenu sous CanvasLayer
	param_button =  $Settings # Accède au bouton ParamButton
	
	# Connecter le signal 'pressed' du bouton Param
	param_button.pressed.connect(self._on_param_button_pressed)
	
	# Initialement, on cache le menu de pause
	pause_menu.visible = false

# Fonction appelée lorsque le bouton Param est pressé
func _on_param_button_pressed() -> void:
	# Inverse la visibilité du menu de pause
	pause_menu.pause()
