import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/track.dart';

class PlaylistScreen extends StatefulWidget {
  // On a besoin du service pour récupérer les données
  final DatabaseService dbService;
  
  const PlaylistScreen({super.key, required this.dbService});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool _isLoading = true;
  List<Track> _likedTracks = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() => _isLoading = true);
    
    // Appel de la nouvelle méthode qu'on vient d'ajouter au service
    final tracks = await widget.dbService.getLikedTracks();
    
    setState(() {
      _likedTracks = tracks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Ma Playlist"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Chargement
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Liste vide
    if (_likedTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Pas encore de recommandation",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              "Swipez à droite pour ajouter des titres !",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 3. Liste des morceaux (Titre en haut, Artiste en dessous)
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _likedTracks.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final track = _likedTracks[index];
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: const Icon(Icons.music_note, color: Colors.blueAccent),
            ),
            title: Text(
              track.trackName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              track.trackArtist,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // On peut ajouter un petit indicateur de style si on veut, sinon rien
            trailing: Text(
              "${track.trackPopularity.toInt()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}