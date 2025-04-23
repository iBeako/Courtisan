extends CheckBox
signal radio_pressed(val : int)

@export var value : int


func _on_pressed() -> void:
	radio_pressed.emit(value)
