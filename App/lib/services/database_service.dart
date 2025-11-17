/// Fichier: lib/services/database_service.dart
///
/// Contient toutes les chaînes de requêtes SQL utilisées par l'application
/// pour interagir avec la base de données SQLite.


class DatabaseQueries {

  
 

  /// Requête pour vérifier si l'utilisateur a interagi avec des morceaux.
  /// Utilisé pour déterminer si l'on est en Cold Start.
  static const String countUserInteractions = '''
    SELECT 
        COUNT(*) AS total_interactions 
    FROM 
        tracks 
    WHERE 
        liked != 0;
  ''';

  // Cold Start
  

  ///Sélectionne les 10 morceaux non vus les plus populaires.
  static const String coldStartTracks = '''
    SELECT
        track_id, 
        track_name, 
        track_artist,
        Cluster_Style
    FROM 
        tracks
    WHERE
        liked = 0 
    ORDER BY
        track_popularity DESC 
    LIMIT 10;
  ''';

  //Profil Utilisateur
 

  /// Calcule le vecteur profil utilisateur (moyenne pondérée des CP).
  /// (Somme des CP aimés - Somme des CP dislikés) / Nombre total de swipes.
  static const String calculateProfileVector = '''
    SELECT
        CAST(SUM(CASE WHEN liked = 1 THEN CP1 ELSE -CP1 END) AS REAL) / COUNT(*) AS avg_cp1,
        CAST(SUM(CASE WHEN liked = 1 THEN CP2 ELSE -CP2 END) AS REAL) / COUNT(*) AS avg_cp2,
        CAST(SUM(CASE WHEN liked = 1 THEN CP3 ELSE -CP3 END) AS REAL) / COUNT(*) AS avg_cp3,
        CAST(SUM(CASE WHEN liked = 1 THEN CP4 ELSE -CP4 END) AS REAL) / COUNT(*) AS avg_cp4,
        CAST(SUM(CASE WHEN liked = 1 THEN CP5 ELSE -CP5 END) AS REAL) / COUNT(*) AS avg_cp5,
        CAST(SUM(CASE WHEN liked = 1 THEN CP6 ELSE -CP6 END) AS REAL) / COUNT(*) AS avg_cp6,
        CAST(SUM(CASE WHEN liked = 1 THEN CP7 ELSE -CP7 END) AS REAL) / COUNT(*) AS avg_cp7,
        CAST(SUM(CASE WHEN liked = 1 THEN CP8 ELSE -CP8 END) AS REAL) / COUNT(*) AS avg_cp8
    FROM 
        tracks
    WHERE 
        liked != 0;
  ''';

  // 4. Logique de Recommandation Hybride (hybride pcq on integre la popularité et les artistes aimés dans la recommandation c'est pas que les swipes)
 

  /// Sélectionne les 7 morceaux les plus proches du profil vectoriel (70%).
  /// Utilise 16 placeholders '?' (2 par CP, pour (CPn - avg_cpn) * (CPn - avg_cpn)).
  static const String findSimilarTracks = '''
    SELECT
        track_id, track_name, track_artist, Cluster_Style, track_popularity,
        (CP1 - ?) * (CP1 - ?) +
        (CP2 - ?) * (CP2 - ?) +
        (CP3 - ?) * (CP3 - ?) +
        (CP4 - ?) * (CP4 - ?) +
        (CP5 - ?) * (CP5 - ?) +
        (CP6 - ?) * (CP6 - ?) +
        (CP7 - ?) * (CP7 - ?) +
        (CP8 - ?) * (CP8 - ?) AS distance_sq
    FROM 
        tracks
    WHERE
        liked = 0 
    ORDER BY 
        distance_sq ASC
    LIMIT 7;
  ''';

  ///Récupère la liste des artistes aimés .
  static const String getLikedArtists = '''
    SELECT DISTINCT
        track_artist
    FROM 
        tracks
    WHERE 
        liked = 1;
  ''';

  ///Sélectionne 3 morceaux non vus basés sur les artistes aimés (30%).
  /// NOTE: La liste des artistes ('?') doit être injectée dynamiquement par Dart.
  static const String findArtistTracks = '''
    SELECT
        track_id, 
        track_name, 
        track_artist,
        Cluster_Style
    FROM 
        tracks
    WHERE
        liked = 0 
        AND track_artist IN (?) -- Placeholder qui sera remplacé par ('Artiste A', 'Artiste B', ...)
    ORDER BY
        track_popularity DESC
    LIMIT 3;
  ''';

  // Logique d'Interaction
  /// Met à jour le statut 'liked' d'un morceau après un swipe.
  /// Nécessite deux paramètres: [status] (1 ou -1) et [track_id].
  static const String updateTrackInteraction = '''
    UPDATE 
        tracks
    SET 
        liked = ? 
    WHERE 
        track_id = ?;
  ''';
}