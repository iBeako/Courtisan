extends PanelContainer

@onready var btn : TextureButton = $MarginContainer/HBoxContainer/MarginContainer/HideButton

@onready var txt : LineEdit = $MarginContainer/HBoxContainer/LineEdit

var hidden_line : bool = true

var texture_hidden : Texture = preload("res://Assets/eye-crossed.svg")

var texture_shown : Texture = preload("res://Assets/eye.svg")

func _on_texture_rect_2_pressed() -> void:
	hidden_line = not hidden_line
	txt.secret = hidden_line
	update_texture()
	
	
func get_value() -> String:
	return txt.text

func set_value(value : String) -> void:
	txt.text = value

func reset_value() -> void:
	txt.text = ""
	txt.secret = true

func update_texture():
	if hidden_line:
		btn.texture_normal = texture_hidden
	else:
		btn.texture_normal = texture_shown
