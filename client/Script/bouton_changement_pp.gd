extends TextureRect

@export var id : int = Network.my_profil_pic

signal pressed




func _on_button_pressed() -> void:
	pressed.emit(self)
