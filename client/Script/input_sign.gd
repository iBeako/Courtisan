extends PanelContainer

@onready var txt : LineEdit = $MarginContainer/HBoxContainer/LineEdit

func get_value() -> String:
	return txt.text

func set_value(value : String) -> void:
	txt.text = value

func reset_value() -> void:
	txt.text = ""
