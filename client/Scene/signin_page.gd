extends VBoxContainer



@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password



func send_infos():
	# --- envoi au serveur
	return {
			"mail" : mail.get_value(),
			"pswd" : pswd.get_value()
		}
