import 'package:flutter/material.dart';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

const kDebugMode = true;
const kNChambers = 6; // the number of chambers the revolver should have
const kLoadedChamberColor = Colors.red;
const kEmptyChamberColor = Colors.green;

void main() {
  runApp(MaterialApp(home: MainScreen()));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int nPlayers = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Revolver"),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: "reset_view",
                child: Text("Reset"),
              )
            ],
            onSelected: (String result) {
              if (result == "reset_view") {
                setState(() {
                  nPlayers = 1;
                });
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              nPlayers++;
            });
          }),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
              nPlayers, (val) => RevolverCardWidget(key: Key(val.toString()))),
        ),
      ),
    );
  }
}

class RevolverCardWidget extends StatefulWidget {
  const RevolverCardWidget({super.key});

  @override
  State<RevolverCardWidget> createState() => _RevolverCardWidgetState();
}

class _RevolverCardWidgetState extends State<RevolverCardWidget> {
  int currentChamber = 0;
  late List<Color> shotColors;
  bool isFiringEnabled = true;
  late int loadedChamberIndex;
  late AudioPlayer _audioPlayer;
  late Random rng;
  final buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.blue,
    backgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    shotColors = List.filled(kNChambers, Colors.black);
    rng = Random();
    loadedChamberIndex = rng.nextInt(kNChambers);
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    rootBundle.loadString('AssetManifest.json').then((manifest) {
      debugPrint(manifest);
    });

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudioAsset(String assetPath) async {
    /// Load an audio asset. Assuming the assetPath is already inside assets/,
    /// so if intending to open assets/audio/audiofile.mp3, it should be
    /// passed in as "audio/audiofile.mp3"
    try {
      await _audioPlayer.setSource(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio: $e');
      }
    }
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final int newLoadedChamberIndex = rng.nextInt(kNChambers);
                setState(() {
                  isFiringEnabled = false;
                  loadedChamberIndex = newLoadedChamberIndex;
                  shotColors = List.filled(kNChambers, Colors.black);
                  currentChamber = 0;
                });
                await _loadAudioAsset("audio/revolver_spin.wav");
                await _playAudio();
                setState(() {
                  isFiringEnabled = true;
                });
              },
              style: buttonStyle,
              child: const Text("Load revolver"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
                kNChambers,
                (int i) => Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: shotColors[i],
                            shape: BoxShape.circle,
                          )),
                    )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: isFiringEnabled
                  ? () async {
// fire current chamber. If it was loaded, game over; else
// increment current chamber. Lock the fire button for one
// second
                      String assetPath;
                      MaterialColor shotColor;
                      bool allowFiringAfterCurrentShot;
                      setState(() {
                        isFiringEnabled = false;
                      });
                      if (currentChamber == loadedChamberIndex) {
// set corresponding circle to "loadedChamberColor"
// lock fire button, only leave reset button
                        assetPath = 'audio/revolver_shot.wav';
                        shotColor = kLoadedChamberColor;
                        allowFiringAfterCurrentShot =
                            false; // only reload should work
                      } else {
// empty chamber
                        assetPath = 'audio/revolver_empty.wav';
                        shotColor = kEmptyChamberColor;
                        allowFiringAfterCurrentShot = true;
                      }
                      await _loadAudioAsset(assetPath);
                      await _playAudio();
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          shotColors[currentChamber] = shotColor;
                          isFiringEnabled = allowFiringAfterCurrentShot;
                          currentChamber++;
                        });
                      });
                    }
                  : null,
              style: buttonStyle,
              child: const Text("Fire"),
            ),
          ),
        ],
      ),
    );
  }
}
