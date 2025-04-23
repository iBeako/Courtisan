extends VBoxContainer


func _ready() -> void:
	$HBoxContainer/OptionButton.select(["cards_new","cards_scan"].find(Global.cards_theme))

func _on_link_button_item_selected(index: int) -> void:
	Global.cards_theme = ["cards_new","cards_scan"][index]
