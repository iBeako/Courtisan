extends Control

var paused : bool = false

var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")

func _ready() -> void:
	hide()
	resume()

func resume():
	$AnimationPlayer.play_backwards("blur")
	paused = false
	await $AnimationPlayer.animation_finished
	if !$AnimationPlayer.is_playing():
		self.visible = false
	
	
func pause():
	self.visible = true
	$AnimationPlayer.play("blur")
	paused = true
	

func escape():
	if Input.is_action_just_pressed("pause|resume") and paused == false:
		pause()
	elif Input.is_action_just_pressed("pause|resume"):
		resume()




func _on_resume_pressed() -> void:
	resume()



func _on_quit_pressed() -> void:
	self.visible = false
	get_tree().change_scene_to_packed(menu_scene)
