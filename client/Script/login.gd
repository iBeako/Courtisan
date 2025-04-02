extends Control

@onready var tab : TabContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer
@onready var signup : VBoxContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer/SignUP
@onready var signin : VBoxContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer/SignIN



func _ready() -> void:
	signup.connect("switch_tab", switch_tab)
	signin.connect("switch_tab", switch_tab)


func switch_tab() -> void:
	print("received emit")

	tab.current_tab = (tab.current_tab + 1) % tab.get_tab_count()
