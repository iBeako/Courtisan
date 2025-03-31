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




func _ready() -> void:
	client = load("res://Script/network.gd").new()
	add_child(client)
	#await get_tree().create_timer(3.0).timeout
	var login = {"message_type":"connexion","login":"login","password":"password"}
	client.send_message_to_server.rpc_id(1,login)
	#await get_tree().create_timer(2.0).timeout
	print(create_zones([1,2,3,4,5]))

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
		zone.id_player = id_players[i]
		zone.Play_ZoneType = PlayZone.PlayZoneType.Ennemie
		print(zone.Play_ZoneType)
		add_child(zone)
		list_zones.append(zone)
	
	return list_zones
