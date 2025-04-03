extends VBoxContainer

signal switch_tab

@onready var mail : PanelContainer = $Email

@onready var pswd : PanelContainer = $Password




func send_infos():
	# --- envoi au serveur
	print(Account.loginAccount(mail.get_value(),pswd.get_value()))


func _on_sign_up_pressed() -> void:
	print("emit")
	switch_tab.emit()
