extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.0
	scale = Vector2(0,0)
	show_msg("Showing text")


func show_msg(msg : String) -> void:
	$MarginContainer/Label.text = msg
	fade_in()

	await get_tree().create_timer(1.5).timeout

	fade_out()

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
	


func _on_resized() -> void:
	pivot_offset = size/2
	print(size)
