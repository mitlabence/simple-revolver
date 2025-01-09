import 'package:flutter/material.dart';
import 'dart:math';

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
  int currentChamber = 0;
  late List<Color> shotColors;
  bool isFiringEnabled = true;
  late int loadedChamberIndex;
  var rng;

  @override
  void initState() {
    super.initState();
    shotColors = List.filled(kNChambers, Colors.black);
    rng = Random();
    loadedChamberIndex = rng.nextInt(kNChambers);
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.blue,
      backgroundColor: Colors.white,
    );
    return Scaffold(
        appBar: AppBar(title: const Text("Revolver")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                    kNChambers,
                    (int i) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: shotColors[i],
                          shape: BoxShape.circle,
                        ))),
              ),
              ElevatedButton(
                  onPressed: () {
                    final int newLoadedChamberIndex = rng.nextInt(kNChambers);
                    setState(() {
                      loadedChamberIndex = newLoadedChamberIndex;
                      shotColors = List.filled(kNChambers, Colors.black);
                      currentChamber = 0;
                      isFiringEnabled = true;
                    });
                  },
                  child: const Text("Load revolver"),
                  style: buttonStyle),
              ElevatedButton(
                onPressed: isFiringEnabled
                    ? () async {
                        // fire current chamber. If it was loaded, game over; else
                        // increment current chamber. Lock the fire button for one
                        // second
                        if (currentChamber == loadedChamberIndex) {
                          // set corresponding circle to "loadedChamberColor"
                          // lock fire button, only leave reset button
                          setState(() {
                            shotColors[currentChamber] = kLoadedChamberColor;
                            isFiringEnabled = true;
                          });
                        }
                        else { // empty chamber
                          setState(() {
                            shotColors[currentChamber] = kEmptyChamberColor;
                            currentChamber++;
                          });
                        }
                        // TODO: in if cases above, select audio, then play
                        // it here. Then wait for it to play (or wait 1 s)
                      }
                    : null,
                child: const Text("Fire"),
                style: buttonStyle,
              ),
            ],
          ),
        ));
  }
}
