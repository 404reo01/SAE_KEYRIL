/// Fichier: lib/models/track.dart
/// Contient les modèles Dart pour représenter les données de la BDD.

// -----------------------------------------------------------------------------
// Modèle 1: Track (Morceau de musique)
// Représente une ligne complète de la table 'tracks'.
// -----------------------------------------------------------------------------
class Track {
  final String trackId;
  final String trackName;
  final String trackArtist;
  final String clusterStyle;
  final double trackPopularity;
  final int liked; // 1: aimé, -1: disliké, 0: non vu

  // 8 Composantes Principales (CP) pour le calcul vectoriel
  final double cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8;

  // Colonne calculée (utile uniquement pour la Requête 2)
  final double? distanceSq;

  Track({
    required this.trackId,
    required this.trackName,
    required this.trackArtist,
    required this.clusterStyle,
    required this.trackPopularity,
    required this.liked,
    required this.cp1,
    required this.cp2,
    required this.cp3,
    required this.cp4,
    required this.cp5,
    required this.cp6,
    required this.cp7,
    required this.cp8,
    this.distanceSq,
  });

  /// Factory constructor pour créer un objet Track à partir d'un Map (résultat SQL).
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      trackId: map['track_id'] as String,
      trackName: map['track_name'] as String,
      trackArtist: map['track_artist'] as String,
      clusterStyle: map['Cluster_Style'] as String,
      trackPopularity: (map['track_popularity'] as num).toDouble(),
      liked: map['liked'] as int,
      
      // Les valeurs de CP sont stockées comme REAL (double) dans SQLite
      cp1: (map['CP1'] as num).toDouble(),
      cp2: (map['CP2'] as num).toDouble(),
      cp3: (map['CP3'] as num).toDouble(),
      cp4: (map['CP4'] as num).toDouble(),
      cp5: (map['CP5'] as num).toDouble(),
      cp6: (map['CP6'] as num).toDouble(),
      cp7: (map['CP7'] as num).toDouble(),
      cp8: (map['CP8'] as num).toDouble(),
      
      // La distance n'est pas toujours présente, donc elle est nullable
      distanceSq: map.containsKey('distance_sq') 
        ? (map['distance_sq'] as num).toDouble() 
        : null,
    );
  }
}

// -----------------------------------------------------------------------------
// Modèle 2: ProfileVector
// Représente le vecteur 8-dimensionnel de l'utilisateur (résultat de la Requête 1).
// -----------------------------------------------------------------------------
class ProfileVector {
  final double avgCp1, avgCp2, avgCp3, avgCp4, avgCp5, avgCp6, avgCp7, avgCp8;

  ProfileVector({
    required this.avgCp1,
    required this.avgCp2,
    required this.avgCp3,
    required this.avgCp4,
    required this.avgCp5,
    required this.avgCp6,
    required this.avgCp7,
    required this.avgCp8,
  });

  /// Factory constructor pour créer un objet ProfileVector à partir du Map (résultat SQL).
  factory ProfileVector.fromMap(Map<String, dynamic> map) {
    // Les résultats sont typiquement renvoyés par SQLite en tant que Map<String, dynamic>
    return ProfileVector(
      avgCp1: (map['avg_cp1'] as num).toDouble(),
      avgCp2: (map['avg_cp2'] as num).toDouble(),
      avgCp3: (map['avg_cp3'] as num).toDouble(),
      avgCp4: (map['avg_cp4'] as num).toDouble(),
      avgCp5: (map['avg_cp5'] as num).toDouble(),
      avgCp6: (map['avg_cp6'] as num).toDouble(),
      avgCp7: (map['avg_cp7'] as num).toDouble(),
      avgCp8: (map['avg_cp8'] as num).toDouble(),
    );
  }

  /// Retourne les 8 valeurs du vecteur sous forme de liste pour l'injection sécurisée dans les requêtes SQL.
  List<double> toSqlParams() {
    return [
      avgCp1, avgCp2, avgCp3, avgCp4, avgCp5, avgCp6, avgCp7, avgCp8,
    ];
  }
}