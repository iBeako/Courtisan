extends Control

@onready var tab : TabContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer
@onready var signup : VBoxContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer/SignUP
@onready var signin : VBoxContainer = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TabContainer/SignIN



func _on_sign_in_switch() -> void:
	#changer de page pour aller au sign in
	tab.current_tab = 0


func _on_sign_up_switch() -> void:
	tab.current_tab = 1


func _on_sign_up_send() -> void:
	print(signup.send_infos())


func _on_sign_in_send() -> void:
	print(signin.send_infos())
