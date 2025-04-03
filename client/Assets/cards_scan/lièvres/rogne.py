from PIL import Image

def crop_image(image_path, output_prefix="cropped_card"):
    """
    Rogner une image en quatre parties égales et sauvegarder chaque partie comme un fichier séparé.

    Args:
        image_path (str): Chemin vers l'image à rogner.
        output_prefix (str): Préfixe pour les noms des fichiers de sortie.
    """
    try:
        img = Image.open(image_path)
        width, height = img.size

        # Calculer les dimensions de chaque carte rognée
        card_width = width // 4
        card_height = height

        # Rogner l'image en quatre parties
        for i in range(4):
            left = i * card_width
            top = 0
            right = (i + 1) * card_width
            bottom = height

            # Rogner la carte
            cropped_card = img.crop((left, top, right, bottom))

            # Sauvegarder la carte rognée
            output_path = f"{output_prefix}_{i + 1}.png"
            cropped_card.save(output_path)
            print(f"Carte rognée sauvegardée : {output_path}")

    except FileNotFoundError:
        print(f"Erreur: Fichier non trouvé à l'emplacement : {image_path}")
    except Exception as e:
        print(f"Une erreur s'est produite: {e}")

# Chemin vers l'image
image_path = "yellow_carte.jpg"

# Rogner l'image
crop_image(image_path)
