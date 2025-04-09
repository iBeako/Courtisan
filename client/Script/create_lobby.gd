extends Control

@onready var name_edit_reference : LineEdit = $PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/LineEdit
var nb_player : int = 5



func _on_check_box_radio_pressed(val: int) -> void:
	nb_player = val
	print(val)
