
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
                try {
                  await _audioPlayer.setAsset("assets/audio/revolver_spin.mp3");
                  await _audioPlayer.play();
                } catch (e) {
                  print(e);
                }
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
                        assetPath = 'assets/audio/revolver_shot.mp3';
                        shotColor = kLoadedChamberColor;
                        allowFiringAfterCurrentShot =
                            false; // only reload should work
                      } else {
// empty chamber
                        assetPath = 'assets/audio/revolver_empty.mp3';
                        shotColor = kEmptyChamberColor;
                        allowFiringAfterCurrentShot = true;
                      }
                      await _audioPlayer.setAsset(assetPath);
                      _audioPlayer.play();
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
