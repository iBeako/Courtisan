extends PanelContainer
class_name friend_line




#func _ready() -> void:
	#update("Test1", 2, true)


func update(f_name : String, f_pp : int, online : bool):
	var friend_name : Label = $MarginContainer/VBoxContainer/Label
	var friend_pp : TextureRect = $MarginContainer/VBoxContainer/TextureRect
	friend_pp.texture = load(Global.profile_pictures[f_pp])
	friend_name.text = f_name
	if online:
		theme = load("res://Assets/Themes/friend_online.tres")
