extends Node2D

# Player identifier
var player_id : int = 1
var client
var zone_scene = preload("res://Scene/play_zone.tscn")
# Dictionary to store the number of cards in each slot
var slot_card_counts: Dictionary = {}

var zone_pos = {
	"2": [{"x": 1098, "y": 224, "rotate": 180}],
	"3": [
		{"x": 786, "y": 224, "rotate": 180},
		{"x": 1818, "y": 224, "rotate": 180}
	],
	"4": [
		{"x": 235, "y": 314, "rotate": 90},
		{"x": 1098, "y": 224, "rotate": 180},
		{"x": 1697, "y": 758, "rotate": -90}
	],
	"5": [
		{"x": 235, "y": 314, "rotate": 90},
		{"x": 786, "y": 224, "rotate": 180},
		{"x": 1818, "y": 224, "rotate": 180},
		{"x": 1697, "y": 1030, "rotate": -90}
	]
}

var zones : Array

func _ready() -> void:
	# Connect signals for each play zone
	#for zone_name in ["PlayZone_Joueur", "PlayZone_Grace", "PlayZone_Disgrace", "PlayZone_Ennemie"]:
	#	if has_node(zone_name):
	#		var zone = get_node(zone_name)
	#		# Assuming each zone has 6 slots
	#		for i in range(1, 7):
	#			var slot_name = "CardSlot" + str(i)  # Ensure slots are correctly named
	#			if zone.has_node(slot_name):
	#				var slot = zone.get_node(slot_name)
	#				# Initialize the card count for this slot
	#				slot_card_counts[zone_name + "/" + slot_name] = 0 
	zones=create_zones([0,-1])

func create_zones(id_players : Array[int]) -> Array:
	if id_players.size() < 2: return []
	$PlayZone_Joueur.id_player = id_players[0]
	var list_zones = [$PlayZone_Joueur]
	var pos : Array = zone_pos[str(id_players.size())] #recup les positions des zones en fonction du nb de joueurs
	
	id_players.remove_at(0)
	for i in id_players.size(): # -1 car on instancie pas la zone du joueur
		var z = pos[i]
		var zone : PlayZone = zone_scene.instantiate()
		zone.position = Vector2(z.x, z.y)
		zone.rotation_degrees = z.rotate
		zone.update_player(id_players[i], "nametest", 0)
		zone.Play_ZoneType = Global.PlayZoneType.ENEMY
		zone.scale = Vector2(0.8, 0.8)
		add_child(zone)
		move_child(zone,3)
		list_zones.append(zone)
	
	return list_zones

func search_zone_by_id(id : int):
	for z in zones:
		if z.id_player == id:
			return z
	return null
