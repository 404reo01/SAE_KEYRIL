CREATE TABLE tracks (
    track_id TEXT NOT NULL PRIMARY KEY,
    track_name TEXT NOT NULL,
    track_artist TEXT,
    
    -- Le vecteur 8-dimensionnel pour le calcul de similarité
    CP1 REAL NOT NULL,
    CP2 REAL NOT NULL,
    CP3 REAL NOT NULL,
    CP4 REAL NOT NULL,
    CP5 REAL NOT NULL,
    CP6 REAL NOT NULL,
    CP7 REAL NOT NULL,
    CP8 REAL NOT NULL,
    
    -- Colonnes pour les règles de recommandation métier
    Cluster_Style TEXT,
    track_popularity REAL NOT NULL, -- Pour la gestion du cold start et de la découverte
    
    -- Colonne pour l'interaction utilisateur (Profil Vectoriel)
    liked INTEGER NOT NULL DEFAULT 0 -- 0: non vu, 1: aimé, -1: disliké (influence négative)
);

