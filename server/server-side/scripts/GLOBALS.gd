extends Node

enum Family {DEFAULT = 0, PAPILLON, CRAPAUD, ROSSIGNOL, LIEVRE, CERF, CARPE}
enum Spec {IDLE = 0, NOBLE, ESPION, ASSASSIN, GARDE}


func family_to_string(f : Family) -> String:
	match f:
		Family.ROSSIGNOL:
			return "rossignol"
		Family.PAPILLON:
			return "papillon"
		Family.CERF:
			return "cerf"
		Family.CRAPAUD:
			return "crapaud"
		Family.CARPE:
			return "carpe"
		Family.LIEVRE:
			return "lievre"
	return "unknown"

func spec_to_string(s : Spec) -> String:
	match s:
		Spec.NOBLE:
			return "noble"
		Spec.ASSASSIN:
			return "assassin"
		Spec.ESPION:
			return "espion"
		Spec.GARDE:
			return "garde"
	return "unknown"

func string_to_family(family_str : String) -> Family:
	match family_str.to_lower():
		"rossignol":
			return Family.ROSSIGNOL
		"papillon":
			return Family.PAPILLON
		"cerf":
			return Family.CERF
		"crapaud":
			return Family.CRAPAUD
		"carpe":
			return Family.CARPE
		"lievre":
			return Family.LIEVRE
		_:
			print("Invalid family string")
	return Family.DEFAULT

func string_to_spec(spec_str : String) -> Spec:
	match spec_str.to_lower():
		"noble":
			return Spec.NOBLE
		"assassin":
			return Spec.ASSASSIN
		"espion":
			return Spec.ESPION
		"garde":
			return Spec.GARDE
		_:
			print("Invalid spec string")
	return Spec.IDLE

# Architecture of data
#var collection = [
	#[], # PAPILLON
	#[], # CRAPAUD
	#[], # ROSSIGNOL
	#[], # LIEVRE
	#[], # CERF
	#[], # CARPE
#]

var players = [
	
] # size of player_max

var queens_table = [
	[], # SPIES
	
	[], # PAPILLON
	[], # CRAPAUD
	[], # ROSSIGNOL
	[], # LIEVRE
	[], # CERF
	[], # CARPE
	
]

func add_player(player_id : int):
	players.append([
		[], # current cards
		
		[], # PAPILLON
		[], # CRAPAUD
		[], # ROSSIGNOL
		[], # LIEVRE
		[], # CERF
		[], # CARPE
		
		player_id,	# id
	])
	print(players)

func remove_player(player_id : int):
	for sublist in players :
		if sublist.size() <= 8 and sublist[7] == player_id:
			players.erase(sublist)
			print("one player {" , player_id, "} has been removed")
			break
	
