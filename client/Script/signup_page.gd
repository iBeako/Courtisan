extends VBoxContainer

@onready var username : PanelContainer = $Username

@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password

@onready var c_pswd : PanelContainer = $Password2


func send_infos():
	# --- envoi au serveur
	if pswd.text == c_pswd.text:
		return Account.createAccount(username.get_value(),mail.get_value(),pswd.get_value())
	return null
