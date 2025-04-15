extends TextureRect

@export var id : int = -1

signal pressed




func _on_button_pressed() -> void:
	pressed.emit(self)
