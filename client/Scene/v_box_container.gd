extends VBoxContainer

var nombre_de_familles = 6
var largeur_famille = 145
var hauteur_famille = 200

func _ready():
	# Configuration du VBoxContainer
	size_flags_vertical = SIZE_FILL  # Permet au conteneur de prendre tout l'espace vertical disponible
	alignment = ALIGN_BEGIN  # Aligner les enfants au début (en haut)

	# Création des emplacements de famille
	for i in range(nombre_de_familles):
		var emplacement = Panel.new()  # ou TextureRect.new()
		emplacement.name = "Famille" + str(i + 1)
		emplacement.size_flags_horizontal = SIZE_FIXED  # Garder la taille horizontale fixe
		emplacement.size_flags_vertical = SIZE_FIXED  # Garder la taille verticale fixe
		emplacement.rect_min_size = Vector2(largeur_famille, hauteur_famille)  # Définir la taille
		add_child(emplacement)

	rect_size.x = largeur_famille  # Ajuster la largeur du VBoxContainer
