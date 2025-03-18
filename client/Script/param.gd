extends Control

@onready var menu = load("res://Scene/menu_principal.tscn")

@onready var tab_container : TabContainer = $MarginContainer/PanelContainer2/HBoxContainer/VBoxContainer/MarginContainer/TabContainer

@onready var tabs : VBoxContainer = $MarginContainer/PanelContainer2/HBoxContainer/PanelContainer/Tabs

var btn_func = [change_to_sound, change_to_profile, change_to_privacy]

func _ready() -> void:
	for i in tab_container.get_tab_count():
		var btn : Button = Button.new()
		var btn_theme = preload("res://Assets/Themes/main_menu_buttons_blank.tres")
		btn.text = tab_container.get_tab_title(i)
		btn.set_theme(btn_theme)
		tabs.add_child(btn)
		
		btn.pressed.connect(btn_func[i])


func change_to_sound():
	tab_container.current_tab=0

func change_to_profile():
	tab_container.current_tab=1
	
func change_to_privacy():
	tab_container.current_tab=2
	

func _on_retour_menu_pressed() -> void:
	print(menu)
	get_tree().change_scene_to_packed(menu)
