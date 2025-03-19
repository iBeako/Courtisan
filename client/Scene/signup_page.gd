extends VBoxContainer

@onready var username : PanelContainer = $Username

@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password

@onready var c_pswd : PanelContainer = $Password2


func send_infos():
	# --- envoi au serveur
	return {
			"user" : username.get_value(),
			"mail" : mail.get_value(),
			"pswd" : pswd.get_value()
		}
