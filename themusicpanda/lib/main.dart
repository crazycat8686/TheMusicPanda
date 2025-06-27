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
  bool nowplaying = false;
  final OnAudioQuery audiofetcher = OnAudioQuery();
  final AudioPlayer audiokit = AudioPlayer();
  IconData butt = Icons.music_note;
  List<SongModel> songs = [];
  var currentsong;
  void initState() {
    super.initState();
    print(currentsong);
    permandget();
    print("fuxxcccc${nowplaying}");

    icons();
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

  void icons() {
    setState(() {
      if (nowplaying) {
        butt = Icons.pause;
      } else {
        butt = Icons.play_arrow_rounded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: songs.isEmpty
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Flexible(
                    flex: 10,
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, i) {
                        var song = songs[i];

                        return GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              nowplaying = false;
                              audiokit.pause();
                            });
                          },
                          onTap: () {
                            currentsong = song;
                            setState(() {
                              nowplaying = true;

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
                  ),
                  if (currentsong != null && currentsong.id != '')
                    Flexible(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(),
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            QueryArtworkWidget(
                              artworkBlendMode: BlendMode.color,
                              artworkBorder: BorderRadius.circular(14),
                              id: currentsong.id,
                              type: ArtworkType.AUDIO,
                              artworkHeight: double.infinity,
                              artworkWidth: 80,
                            ),
                            SizedBox(width: 15),
                            Flexible(
                              child: Text(
                                currentsong.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lexm',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  playorpause(currentsong);
                                });
                              },
                              icon: Icon(butt),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
