extends Control

func set_label_text(text: String):
	$Label.text = text

func instantiate_waiting_scene(text: String) -> void:
	var new_scene = load("res://Scene/InstantiateWaiting.tscn").instantiate()
	
	# Tu met le pseudo de l'user entre les parenthese ici ------------------------------
	new_scene.set_label_text(text)
	# -----------------------------------------------------------------------------
	# Ajout dans le conteneur cible
	var target_container = $PanelContainer/VBoxContainer/VBoxContainer
	target_container.add_child(new_scene)

func _on_arrow_2_pressed() -> void:
	print("clicked")
	#----------------------------------------------------------------------------
	# Ici tu met ta fonction pour lancer ta partie 
#-------------------------------------------------
