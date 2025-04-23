extends VBoxContainer

signal switch_tab

@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password




func send_infos():
	# --- envoi au serveur
	var mes = Account.loginAccount(mail.get_value(),pswd.get_value())
	print(mes)
	Network.send_message_to_server.rpc_id(1,mes)


func _on_sign_up_pressed() -> void:
	print("emit")
	switch_tab.emit()
