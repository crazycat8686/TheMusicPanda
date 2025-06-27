import 'dart:ffi';

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
  IconData butt = Icons.music_note;
  List<SongModel> songs = [];
  var currentsong;
  bool visbigd = false;
  bool nowplaying = false;

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

  Future<void> playorpause(SongModel song) async {
    setState(() async {
      if (nowplaying) {
        print("condition1");
        print("condition1");
        print("condition1");

        audiokit.pause();
        nowplaying = false;

        setState(() {
          icons(false);
        });
        print(nowplaying);
      } else {
        print("condition2");
        print("condition2");
        print("condition2");
        audiokit.play();
        nowplaying = true;

        setState(() {
          icons(true);
        });
        print(nowplaying);
      }
    });
  }

  Future<void> icons(bool r) async {
    if (r) {
      butt = Icons.pause;
    } else {
      butt = Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: songs.isEmpty
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Flexible(
                    flex: 8,
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, i) {
                        var song = songs[i];

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              currentsong = song;
                              nowplaying = true;

                              icons(true);
                            });
                            await audiokit.setAudioSource(
                              AudioSource.uri(Uri.parse(song.uri!)),
                            );
                            await audiokit.play();
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
                  Visibility(
                    visible: visbigd,
                    child: Flexible(
                      flex: 35,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            visbigd = false;
                          });
                        },
                        child: Container(
                          height: 1000,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(72, 34, 150, 222),
                            borderRadius: BorderRadiusDirectional.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (currentsong != null && currentsong.id != '')
                    Visibility(
                      visible: !visbigd,
                      child: Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              visbigd = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(207, 250, 204, 204),

                              borderRadius: BorderRadius.circular(26),
                            ),
                            padding: EdgeInsets.only(
                              top: 3,
                              bottom: 0,
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                StreamBuilder<Duration>(
                                  stream: audiokit.positionStream,
                                  builder: (context, snapshot) {
                                    var position =
                                        snapshot.data ?? Duration.zero;
                                    var duration =
                                        audiokit.duration ?? Duration.zero;
                                    return FractionallySizedBox(
                                      widthFactor: 0.89,
                                      child: LinearProgressIndicator(
                                        borderRadius: BorderRadius.circular(40),
                                        value:
                                            duration.inMilliseconds
                                                    .toDouble() ==
                                                0
                                            ? 0
                                            : position.inMilliseconds
                                                      .toDouble() /
                                                  duration.inMilliseconds
                                                      .toDouble(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRect(
                                      child: QueryArtworkWidget(
                                        artworkBlendMode: BlendMode.color,
                                        artworkBorder: BorderRadius.circular(
                                          14,
                                        ),
                                        id: currentsong.id,
                                        type: ArtworkType.AUDIO,
                                        artworkHeight: 60,
                                        artworkWidth: 80,
                                      ),
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
                                        playorpause(currentsong);
                                      },
                                      icon: Icon(butt),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
