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
  List<AlbumModel> albums = [];

  var previoussong;
  var currentsong;
  var nextsong;
  var currin;
  var nextin;
  var previn;

  bool visbigd = false;
  bool nowplaying = false;

  void initState() {
    super.initState();
    permandget();
    albumget();
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

  Future<void> albumget() async {
    final perm = await Permission.audio.request();
    if (perm.isGranted) {
      List<AlbumModel> tempalb = await audiofetcher.queryAlbums();
      setState(() {
        albums = tempalb;
      });
    } else {
      openAppSettings();
    }
  }

  Future<void> playorpause(SongModel song) async {
    setState(() async {
      if (nowplaying) {
        audiokit.pause();
        nowplaying = false;

        setState(() {
          icons(false);
        });
      } else {
        audiokit.play();
        nowplaying = true;

        setState(() {
          icons(true);
        });
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

  Future<void> plnext() async {
    setState(() {
      previn = currin;
      previoussong = songs[currin];
      currin = nextin;
      currentsong = songs[nextin];
      nextin += 1;
      nextsong = songs[nextin];
      nowplaying = true;
      icons(true);
    });
    await audiokit.setAudioSource(AudioSource.uri(Uri.parse(currentsong.uri!)));
    await audiokit.play();
  }

  Future<void> plprev() async {
    setState(() {
      nextsong = songs[currin];
      nextin = currin + 1;
      currentsong = songs[previn];
      currin -= 1;
      previn = currin - 1;
      previoussong = songs[previn];

      nowplaying = true;
      icons(true);
    });
    await audiokit.setAudioSource(AudioSource.uri(Uri.parse(currentsong.uri!)));
    await audiokit.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          child: TextField(decoration: InputDecoration(hintText: 'enter')),
        ),
      ),
      backgroundColor: Colors.white,
      body: songs.isEmpty
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  // if (currentsong == null && currentsong.id == '')
                  Visibility(
                    visible: !visbigd,
                    child: FittedBox(
                      child: Container(
                        margin: EdgeInsets.only(top: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "View ur Albums here",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 40),
                            SizedBox(
                              height: 140,
                              width: 400,
                              child: PageView.builder(
                                controller: PageController(
                                  viewportFraction: 0.7,
                                ),
                                itemCount: albums.length,
                                itemBuilder: (context, i) {
                                  return AnimatedContainer(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    height: 205,
                                    width: 300,
                                    duration: Duration(milliseconds: 600),
                                    curve: Curves.bounceInOut,
                                    child: QueryArtworkWidget(
                                      id: albums[i].id,
                                      type: ArtworkType.ALBUM,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 34,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, i) {
                          var song = songs[i];

                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                currentsong = song;
                                previoussong = (i > 0) ? songs[i - 1] : null;
                                nextsong = (i < songs.length - 1)
                                    ? songs[i + 1]
                                    : null;

                                nowplaying = true;
                                currin = i;
                                nextin = (i < songs.length - 1)
                                    ? currin + 1
                                    : null;
                                previn = (i > 0) ? currin - 1 : null;

                                icons(true);
                              });
                              await audiokit.setAudioSource(
                                AudioSource.uri(Uri.parse(song.uri!)),
                              );
                              await audiokit.play();
                              await audiokit.seekToNext();
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
                  ),
                  if (currentsong != null && currentsong.id != '')
                    Visibility(
                      visible: visbigd,
                      child: Flexible(
                        flex: 100,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              visbigd = false;
                            });
                          },
                          child: Container(
                            height: 1000,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(71, 253, 222, 222),
                              borderRadius: BorderRadiusDirectional.circular(
                                30,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                Text(
                                  textAlign: TextAlign.center,
                                  currentsong.title,
                                  style: TextStyle(
                                    fontFamily: 'Lexb',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  currentsong.artist,
                                  style: TextStyle(
                                    fontFamily: 'Lexr',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  width: 300,

                                  child: Flexible(
                                    child: ClipRRect(
                                      child: QueryArtworkWidget(
                                        artworkBorder: BorderRadius.circular(
                                          30,
                                        ),
                                        id: songs[currin].id,
                                        type: ArtworkType.AUDIO,
                                        artworkHeight: 100,
                                        artworkWidth: 100,
                                      ),
                                    ),
                                  ),
                                ),

                                StreamBuilder<Duration>(
                                  stream: audiokit.positionStream,
                                  builder: (context, snap) {
                                    var position = snap.data ?? Duration.zero;
                                    var duration =
                                        audiokit.duration ?? Duration.zero;

                                    return Slider(
                                      value: position.inMilliseconds.toDouble(),
                                      onChanged: (onChanged) {},
                                      min: 0,
                                      max: duration.inMilliseconds.toDouble(),
                                    );
                                  },
                                ),
                                Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            playorpause(currentsong);
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
                        ),
                      ),
                    ),

                  if (currentsong != null && currentsong.id != '')
                    Visibility(
                      visible: !visbigd,
                      child: Expanded(
                        flex: 9,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              visbigd = true;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 4,
                              left: 5,
                              right: 5,
                            ),

                            decoration: BoxDecoration(
                              color: const Color.fromARGB(207, 250, 204, 204),

                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: EdgeInsets.only(
                              top: 3,
                              bottom: 3,
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 2),
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
                                SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRect(
                                      child: QueryArtworkWidget(
                                        artworkBlendMode: BlendMode.color,
                                        artworkBorder: BorderRadius.circular(
                                          30,
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
                                SizedBox(height: 2.8),
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
