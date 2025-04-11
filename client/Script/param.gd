extends Control

@onready var menu = load("res://Scene/menu_principal.tscn")

@onready var button_pp = preload("res://Scene/bouton_changement_pp.tscn")

@onready var tab_container : TabContainer = $PanelContainer2/HBoxContainer/VBoxContainer/MarginContainer/TabContainer

@onready var tabs : VBoxContainer = $PanelContainer2/HBoxContainer/PanelContainer/Tabs
var pic_image: int
var pseudo: String
var btn_func = [change_to_sound, change_to_profile, change_to_privacy]

func _ready() -> void:
	for i in tab_container.get_tab_count():
		var btn : Button = Button.new()
		var btn_theme = preload("res://Assets/Themes/main_menu_buttons_blank.tres")
		btn.text = tab_container.get_tab_title(i)
		btn.set_theme(btn_theme)
		tabs.add_child(btn)
		tabs.move_child(btn,2+i) #place le bouton dans le bon ordre 
		
		btn.pressed.connect(btn_func[i])
	
	for p in Global.profile_pictures.size():
		var button : Control = button_pp.instantiate()
		button.texture = load(Global.profile_pictures[p])
		button.id=p
		button.pressed.connect(change_pp)
		$PanelContainer2/HBoxContainer/VBoxContainer/MarginContainer/TabContainer/Profile/GridContainer.add_child(button)

func change_to_sound():
	tab_container.current_tab=0

func change_to_profile():
	tab_container.current_tab=1

func change_to_privacy():
	tab_container.current_tab=2

func change_pp(btn_clicked : Control) -> void:
	$PanelContainer2/HBoxContainer/VBoxContainer/MarginContainer/TabContainer/Profile/VBoxContainer/PanelContainer/CurrentPP.texture = btn_clicked.texture
	#TODO envoyer message
	pic_image = btn_clicked.id
	print(btn_clicked.id)


func _on_texture_button_pressed() -> void:
	var message = {
		"message_type":"change_profil",
		"username":Network.username,
		"pseudo":pseudo,
		"pic_profile":pic_image
	}
	print(message)
	Network.send_message_to_server.rpc_id(1,message)
	get_tree().change_scene_to_packed(menu)

func _on_text_edit_text_submitted(new_text: String) -> void:
	$PanelContainer2/HBoxContainer/VBoxContainer/MarginContainer/TabContainer/Profile/VBoxContainer/NameEdit.release_focus()
	pseudo = new_text
	print(new_text)
	#TODO envoyer message
