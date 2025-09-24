import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class GameBackground extends StatefulWidget {
  const GameBackground({super.key});

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground> {
  rive.Artboard? cloudArtboard, cloudArtboard2;
  rive.StateMachineController? cloudController, cloudController2;

  @override
  void initState() {
    super.initState();
    _loadClouds();
  }

  Future<void> _loadClouds() async {
    final cloudsFile = await loadRiveButton(
      assetPath: 'assets/Rive_Files/animated_clouds2.riv',
      stateMachineName: 'Clouds',
      triggerName: null,
    );
    final cloudsFile2 = await loadRiveButton(
      assetPath: 'assets/Rive_Files/animated_clouds2.riv',
      stateMachineName: 'Clouds',
      triggerName: null,
    );

    if (mounted) {
      setState(() {
        cloudArtboard = cloudsFile.artboard;
        cloudController = cloudsFile.controller;

        cloudArtboard2 = cloudsFile2.artboard;
        cloudController2 = cloudsFile2.controller;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFAADDE0),
                Color(0xFFCBE9DF),
                Color(0xFFEBF3DE),
              ],
            ),
          ),
        ),

        // Clouds
        if (cloudArtboard2 != null)
          Positioned(
            top: 0,
            bottom: 150,
            child: SizedBox(
              width: 900,
              height: 900,
              child: rive.Rive(
                artboard: cloudArtboard2!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        if (cloudArtboard != null)
          Positioned(
            top: 0,
            bottom: 100,
            child: SizedBox(
              width: 1000,
              height: 1000,
              child: rive.Rive(
                artboard: cloudArtboard!,
                fit: BoxFit.contain,
              ),
            ),
          ),

        // Bottom image (ground / hills)
        Positioned(
          bottom: 0,
          child: Image.asset(
            'assets/bg_files/game_bg.png',
            height: 130,
            fit: BoxFit.fitWidth,
          ),
        ),
      ],
    );
  }
}
