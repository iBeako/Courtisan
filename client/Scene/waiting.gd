extends Control
var menu = preload("res://Scene/menu_principal.tscn")
func set_label_text(text: String):
	$Label.text = text

func instantiate_waiting_scene(text: String) -> void:
	var new_scene = load("res://Scene/InstantiateWaiting.tscn").instantiate()
	
	# Tu met le pseudo de l'user entre les parenthese ici ------------------------------
	new_scene.set_label_text(text)
	# -----------------------------------------------------------------------------
	# Ajout dans le conteneur cible
	var target_container = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/VBoxContainer")

	target_container.add_child(new_scene)

func _on_arrow_2_pressed() -> void:
	print("clicked")
	var message = {
		"message_type":"start_lobby",
		"id_lobby":Network.id_lobby,
		"username":Network.username
	}
	Network.send_message_to_server.rpc_id(1,message)
	#----------------------------------------------------------------------------
	# Ici tu met ta fonction pour lancer ta partie 
#-------------------------------------------------


func _on_arrow_pressed() -> void:
	print("clicked")
	var message = {
		"message_type":"quit_lobby",
		"id_lobby":Network.id_lobby,
		"username":Network.username
	}
	Network.send_message_to_server.rpc_id(1,message)
	get_tree().change_scene_to_packed(menu)
