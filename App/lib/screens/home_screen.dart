import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/playlist_screen.dart';
import '../services/database_service.dart';
import '../models/track.dart';


class MyHomeScreen extends StatefulWidget {
  // Le service de BDD est injecté (reçu) depuis main.dart
  final DatabaseService dbService; 
  const MyHomeScreen({super.key, required this.dbService});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 0; 
  bool _isLoading = true;
  int _currentTrackIndex = 0;
  List<Track> _recommendations = [];
  String _currentStrategy = "Cold Start"; // Variable pour l'affichage de la stratégie

  @override
  void initState() {
    super.initState();
    // Au démarrage, on utilise la logique hybride qui gère le Cold Start si < 5 interactions
    _fetchHybridRecommendations();
  }

  // Fonction pour charger les recommandations (gère Cold Start ou Hybride)
  Future<void> _fetchHybridRecommendations() async {
    setState(() {
      _isLoading = true;
    });
    
    // 1. Déterminer la stratégie et charger les morceaux
    // Cette fonction vérifie le nombre d'interactions utilisateur dans la BDD.
    final int interactionCount = await widget.dbService.countInteractions();
    
    final List<Track> tracks;
    if (interactionCount < 5) {
      // Moins de 5 interactions -> Mode Cold Start
      tracks = await widget.dbService.getColdStartTracks();
      _currentStrategy = "Démarrage à Froid";
    } else {
      // 5 interactions ou plus -> Mode Hybride
      tracks = await widget.dbService.getHybridRecommendations();
      _currentStrategy = "Hybride (Personnalisé)";
    }

    // 2. Mise à jour de l'état
    setState(() {
      _recommendations = tracks;
      _isLoading = false;
      _currentTrackIndex = 0;
      // Affichage d'un log pour suivre le changement de stratégie
      print("LOG: Nouvelle session. Stratégie actuelle: $_currentStrategy. Morceaux: ${_recommendations.length}");
    });
  }

  // Gère le clic sur Like (true) ou Dislike (false)
  void _onSwipe(bool liked) async {
    if (_recommendations.isEmpty) return;

    final Track currentTrack = _recommendations[_currentTrackIndex];
    final int status = liked ? 1 : -1;

    // 1. Mettre à jour la base de données (enregistre l'interaction)
    await widget.dbService.updateInteraction(currentTrack.trackId, status);
    
    // 2. Passer au morceau suivant
    setState(() {
      _currentTrackIndex++;
    });

    // 3. Vérifier si tous les morceaux de la session actuelle ont été vus
    if (_currentTrackIndex >= _recommendations.length) {
      // Si la liste est épuisée, on recharge la prochaine session de 10 morceaux
      // La fonction _fetchHybridRecommendations() choisit la bonne stratégie.
      await _fetchHybridRecommendations(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Si l'application charge, affiche l'indicateur
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              // Affiche dynamiquement la stratégie de chargement
              Text("Chargement ($_currentStrategy)..."), 
            ],
          ),
        ),
      );
    }

    // Si la liste est vide après le chargement
    if (_recommendations.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Aucun morceau trouvé. Vérifiez la connexion à la BDD."),
        ),
      );
    }
    
    // Le morceau actuel à afficher
    final Track trackActuel = _recommendations[_currentTrackIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // Affiche la stratégie actuelle dans le titre
        title: Text("KEYRIL Recommandation ($_currentStrategy)"), 
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // --- Carte d'Affichage du Morceau (Zone de Swipe) ---
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700, 
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Artiste
                    Text(
                      trackActuel.trackArtist, 
                      style: TextStyle(
                        fontSize: 18, 
                        color: Colors.white70, 
                        fontWeight: FontWeight.w300
                      )
                    ),
                    const SizedBox(height: 8),
                    // Titre du Morceau
                    Text(
                      trackActuel.trackName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15),
                    // Affichage des informations techniques
                    Text(
                      'Popularité: ${trackActuel.trackPopularity.toStringAsFixed(1)}\nStyle: ${trackActuel.clusterStyle}',
                      style: const TextStyle(
                        fontSize: 14, 
                        color: Colors.white60
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- Boutons de Swipe (Aimé/Disliké) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Bouton Disliké (Rouge)
                FloatingActionButton(
                  heroTag: "dislikeBtn",
                  onPressed: () => _onSwipe(false),
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.close, size: 30),
                ),
                const SizedBox(width: 40),
                // Bouton Aimé (Vert)
                FloatingActionButton(
                  heroTag: "likeBtn",
                  onPressed: () => _onSwipe(true),
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.favorite, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
      
      // --- Barre de Navigation (Navbar) ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex, 
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.queue_music_rounded), label: "Playlist"),
        ],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            // Navigation vers l'écran de Playlist
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => PlaylistScreen(dbService: widget.dbService),
              ),
            ).then((_) {
              // Réinitialiser l'index à l'accueil après le retour
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
        },
      ),
    );
  }
}