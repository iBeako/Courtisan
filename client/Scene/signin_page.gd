extends VBoxContainer



@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password




func send_infos():
	# --- envoi au serveur
	return Account.loginAccount(mail.get_value(),pswd.get_value())
