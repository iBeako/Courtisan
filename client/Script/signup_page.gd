extends VBoxContainer

signal switch_tab

@onready var username : PanelContainer = $Username

@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password

@onready var c_pswd : PanelContainer = $Password2


func send_infos():
	# --- envoi au serveur
	if pswd.get_value() == c_pswd.get_value():
		if "@" in mail.get_value():
			var mes =Account.createAccount(username.get_value(),mail.get_value(),pswd.get_value())
			print(mes)
			Network.send_message_to_server.rpc_id(1,mes)
		else:
			print("email not valid")
	else:
		print("password not the same")


func _on_sign_in_pressed() -> void:
	switch_tab.emit()
