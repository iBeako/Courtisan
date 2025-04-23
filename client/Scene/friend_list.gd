extends HBoxContainer
var is_open : bool = false

var initial_position : Vector2
var closed_position : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize(
		[{
			"name" : "1",
			"pp" : 1,
			"online" : true
		},
		{
			"name" : "2",
			"pp" : 2,
			"online" : false
		}
		]
	) # TODO
	initial_position = position
	position.x += 414 #size.x - $PanelContainer2.size.x	
	closed_position = position
	
	$PanelContainer/VBoxContainer/MarginContainer/HBoxContainer/Label.text = Network.pseudo
	$PanelContainer/VBoxContainer/MarginContainer/HBoxContainer/PanelContainer/TextureRect.texture = load(Global.profile_pictures[Network.my_profil_pic])
	


func initialize(friends : Array) -> void:
	var line_scene = load("res://Scene/friend_line.tscn")
	for friend in friends:
		print(friend["pp"])
		var line : friend_line = line_scene.instantiate()
		line.update(friend["name"],friend["pp"],friend["online"])
		$PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(line)


func _on_line_edit_text_submitted(new_text: String) -> void:
	$PanelContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/LineEdit.text = ""
	print(new_text, "a envoyer au serveur") #TODO


func open() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", initial_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_open = true
	
func close() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", closed_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_open = false

func _on_button_pressed() -> void:
	if is_open:
		close()
	else:
		open()
	return
