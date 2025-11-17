#script Python pour créer et remplir la BDD (À exécuter une seule fois UNE SEULE FOIS LES REUFS UNE SEULE FOIS)
import pandas as pd
import sqlite3

# 1. Charger le DataFrame final
df = pd.read_csv('spotify_data_preprocessed_final.csv')

# 2. Ajout de la colonne 'liked' (doit être fait avant l'exportation vers SQL)
df['liked'] = 0 
# Cette colonne est essentielle pour le profil utilisateur, par défaut à 0 (non vu)

# 3. Créer la connexion à la BDD (le fichier sera créé s'il n'existe pas)
conn = sqlite3.connect('app_data.db')

# 4. Écrire le DataFrame dans la table 'tracks'
# 'if_exists='replace'' recrée la table si elle existe déjà.
# 'index=False' assure que l'index de Pandas n'est pas ajouté comme colonne.
df.to_sql('tracks', conn, if_exists='replace', index=False)

# 5. Fermer la connexion
conn.close()

print("Fichier app_data.db créé et rempli avec succès. Il contient la table 'tracks'.")