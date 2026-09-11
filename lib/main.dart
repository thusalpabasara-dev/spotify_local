import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const LocalSpotifyApp());

class LocalSpotifyApp extends StatelessWidget {
  const LocalSpotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Player',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1DB954),
      ),
      home: const LibraryScreen(),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
        ),
        builder: (context, item) {
          if (item.data == null) return const Center(child: CircularProgressIndicator());
          if (item.data!.isEmpty) return const Center(child: Text("No MP3s found in Apple Music"));

          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(Icons.music_note, color: Colors.grey),
                ),
                title: Text(item.data![index].title, maxLines: 1),
                subtitle: Text(item.data![index].artist ?? "Unknown Artist"),
                onTap: () {
                  _player.setAudioSource(
                    AudioSource.uri(Uri.parse(item.data![index].uri!))
                  );
                  _player.play();
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: const Color(0xFF282828), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.skip_previous, color: Colors.white, size: 36),
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
              onPressed: () {
                _player.playing ? _player.pause() : _player.play();
              },
            ),
            const Icon(Icons.skip_next, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}