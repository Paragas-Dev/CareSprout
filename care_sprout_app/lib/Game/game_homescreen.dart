import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class GameHomescreen extends StatefulWidget {
  const GameHomescreen({super.key});

  @override
  State<GameHomescreen> createState() => _GameHomescreenState();
}

class _GameHomescreenState extends State<GameHomescreen> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController,
      cloudController,
      cloudController2;
  rive.Artboard? backArtboard, cloudArtboard, cloudArtboard2;

  //game lists
  final List<String> _games = [
    'Alphabet',
    'Numbers',
    'Colors',
    'Animals',
    'Shapes',
    'Memory',
  ];

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
  }

  Future<void> _loadRiveAssets() async {
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );

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
    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      cloudArtboard = cloudsFile.artboard;
      cloudController = cloudsFile.controller;

      cloudArtboard2 = cloudsFile2.artboard;
      cloudController2 = cloudsFile2.controller;
    });
  }

  void _onTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/bg_files/game_bg.png',
              height: 130,
              fit: BoxFit.fitWidth,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    if (backArtboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: rive.Rive(
                            artboard: backArtboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: <Color>[
                              Color(0xFFB3D981),
                              Color(0xFFBF8C33),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Games",
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'Luckiest Guy',
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF34732F),
                                    offset: Offset(2, 2),
                                    blurRadius: 3,
                                  ),
                                ],
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 200,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      return GameCard(
                        gameName: _games[index],
                        onTap: () {
                          debugPrint('Tapped on ${_games[index]}');
                        },
                        riveAssetPath: 'assets/Rive_Files/gamebox.riv',
                        riveStateMachineName: 'Game Box',
                        riveTriggerName: 'GB Click',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class GameCard extends StatefulWidget {
  final String gameName;
  final VoidCallback onTap;
  final String riveAssetPath;
  final String riveStateMachineName;
  final String riveTriggerName;

  const GameCard({
    super.key,
    required this.gameName,
    required this.onTap,
    required this.riveAssetPath,
    required this.riveStateMachineName,
    required this.riveTriggerName,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  rive.SMITrigger? gbClick;
  rive.StateMachineController? gameBoxController;
  rive.Artboard? gameboxArtboard;
  bool isRiveLoaded = false;

  @override
  initState() {
    _loadCardRiveAssets();
    super.initState();
  }

  Future<void> _loadCardRiveAssets() async {
    final cardRiveData = await loadRiveButton(
      assetPath: widget.riveAssetPath,
      stateMachineName: widget.riveStateMachineName,
      triggerName: widget.riveStateMachineName,
    );

    if (mounted) {
      setState(() {
        gameboxArtboard = cardRiveData.artboard;
        gameBoxController = cardRiveData.controller;
        gbClick = cardRiveData.trigger;
        isRiveLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    gameBoxController?.dispose();
    super.dispose();
  }

  void _onGameBoxTap() {
    if (gbClick != null) {
      AudioService().playClickSound();
      gbClick!.fire();
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onGameBoxTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isRiveLoaded)
            Positioned.fill(
              child: rive.Rive(
                artboard: gameboxArtboard!,
                fit: BoxFit.contain,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              widget.gameName,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Luckiest Guy',
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          )
        ],
      ),
    );
  }
}
