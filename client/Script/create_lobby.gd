extends Control

@onready var name_edit_reference : LineEdit = $PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/LineEdit
@onready var my_checkbox: CheckBox = $PanelContainer/VBoxContainer/MarginContainer3/CheckBox
var nb_player : int = 5



func _on_check_box_radio_pressed(val: int) -> void:
	nb_player = val
	print(val)



func _on_button_pressed():
	var name_text := name_edit_reference.text
	var is_checked := my_checkbox.button_pressed
	#{"message_type:"create_lobby","id_player":id,"name":"name","number_of_player":number_of_player,"have_password":0}
	#{"message_type:"create_lobby","id_player":id,"name":"name","number_of_player":number_of_player,"have_password":1,"password":"password"}
	var message = {
		"message_type":"create_lobby",
		"username":Network.username,
		"name":name_text,
		"number_of_player":nb_player,
		"have_password":0
	}
	if is_checked:
		message["have_password"]=0
	else:
		message["have_password"]=1
	print(message)
	Network.send_message_to_server.rpc_id(1,message)
