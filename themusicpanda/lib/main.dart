import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: djpanda()));
}

class djpanda extends StatefulWidget {
  const djpanda({super.key});

  @override
  State<djpanda> createState() => _djpandaState();
}

class _djpandaState extends State<djpanda> {
  final OnAudioQuery audiofetcher = OnAudioQuery();
  final AudioPlayer audiokit = AudioPlayer();
  List<SongModel> songs = [];
  var currentsong;
  void initState() {
    super.initState();
    permandget();
  }

  Future<void> permandget() async {
    final perm = await Permission.audio.request();
    if (perm.isGranted) {
      List<SongModel> tempsongs = await audiofetcher.querySongs();
      setState(() {
        songs = tempsongs;
      });
    } else {
      openAppSettings();
    }
  }

  void playorpause(SongModel song) async {
    await audiokit.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    await audiokit.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(111222),
      body: songs.isEmpty
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) {
                var song = songs[i];

                return GestureDetector(
                  onTap: () {
                    currentsong = song;
                    setState(() {
                      playorpause(song);
                    });
                  },
                  child: ListTile(
                    title: Text(song.title),
                    leading: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.circular(12),
                      nullArtworkWidget: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/panda.png',
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    subtitle: Text(song.artist ?? "Djpanda"),
                  ),
                );
              },
            ),
    );
  }
}
