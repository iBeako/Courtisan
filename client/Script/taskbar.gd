extends Node
@onready var taskbar_label = $Panel/ActionPlayed
@onready var taskbar_panel = $Panel

func print_action(action: String) -> void:
	taskbar_label.text = action



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
