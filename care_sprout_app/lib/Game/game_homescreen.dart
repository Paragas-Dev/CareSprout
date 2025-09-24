// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_to_list_in_spreads

import 'package:care_sprout/Components/game_background.dart';
import 'package:care_sprout/Game/level_select_screen.dart';
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
  rive.SMITrigger? backClick,
      interventionClick,
      faClick,
      transitionClick,
      tlpClick;
  rive.StateMachineController? backController,
      interventionController,
      faController,
      transitionController,
      tlpController;
  rive.Artboard? backArtboard,
      interventionArtboard,
      faArtboard,
      transitionArtboard,
      tlpArtboard;

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

    final interventionBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/intervention_class.riv',
      stateMachineName: 'Intervention',
      triggerName: 'click',
    );

    final faBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/fa_class.riv',
      stateMachineName: 'FC class',
      triggerName: 'click',
    );

    final transitionBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/transition_class.riv',
      stateMachineName: 'Transition Class',
      triggerName: 'click',
    );

    final tlpBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/tlp_class.riv',
      stateMachineName: 'TLP Class',
      triggerName: 'click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      interventionArtboard = interventionBtn.artboard;
      interventionController = interventionBtn.controller;
      interventionClick = interventionBtn.trigger;

      faArtboard = faBtn.artboard;
      faController = faBtn.controller;
      faClick = faBtn.trigger;

      transitionArtboard = transitionBtn.artboard;
      transitionController = transitionBtn.controller;
      transitionClick = transitionBtn.trigger;

      tlpArtboard = tlpBtn.artboard;
      tlpController = tlpBtn.controller;
      tlpClick = tlpBtn.trigger;
    });
  }

  void _onTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Reset to portrait only when leaving game section
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
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
    backController?.dispose();
    interventionController?.dispose();
    faController?.dispose();
    transitionController?.dispose();
    tlpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 250.0;
    const double cardHeight = 200.0;

    const double riveWidth = 350.0;
    const double riveHeight = cardHeight;

    final List<Map<String, dynamic>> _allItems = [
      {
        'type': 'rive',
        'name': 'Intervention',
        'artboard': interventionArtboard,
        'trigger': interventionClick,
        'width': riveWidth,
        'height': riveHeight,
      },
      {
        'type': 'rive',
        'name': 'Functional Academics',
        'artboard': faArtboard,
        'trigger': faClick,
        'width': riveWidth,
        'height': riveHeight,
      },
      {
        'type': 'rive',
        'name': 'Transitional',
        'artboard': transitionArtboard,
        'trigger': transitionClick,
        'width': riveWidth,
        'height': riveHeight,
      },
      {
        'type': 'rive',
        'name': 'Transition Livelihood Program',
        'artboard': tlpArtboard,
        'trigger': tlpClick,
        'width': riveWidth,
        'height': riveHeight,
      },
      ..._games
          .map((gameName) => {'type': 'gamecard', 'name': gameName})
          .toList(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const GameBackground(),
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
                const SizedBox(height: 50),
                SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 0),
                    itemCount: _allItems.length,
                    itemBuilder: (context, index) {
                      final item = _allItems[index];
                      if (item['type'] == 'rive') {
                        final rive.Artboard? artboard =
                            item['artboard'] as rive.Artboard?;
                        final rive.SMITrigger? trigger =
                            item['trigger'] as rive.SMITrigger?;

                        return SizedBox(
                          width: riveWidth,
                          height: riveHeight,
                          child: RiveCard(
                            artboard: artboard,
                            trigger: trigger,
                            onTap: () {
                              if (trigger != null) {
                                AudioService().playClickSound();
                                trigger.fire();
                              }
                              // then open the level select for this category
                              final name = item['name'] as String?;
                              if (name != null) {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LevelSelectScreen(category: name),
                                    ),
                                  );
                                });
                              }
                            },
                            width: riveWidth,
                            height: riveHeight,
                            fit: BoxFit.contain,
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: GameCard(
                            gameName: item['name'],
                            onTap: () {
                              debugPrint('Tapped on ${item['name']}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LevelSelectScreen(
                                    category: item['name'],
                                  ),
                                ),
                              );
                            },
                            riveAssetPath: 'assets/Rive_Files/gamebox.riv',
                            riveStateMachineName: 'Game Box',
                            riveTriggerName: 'GB Click',
                          ),
                        );
                      }
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

  double _scale = 1.0;
  double _iconScale = 1.0;

  @override
  initState() {
    _loadCardRiveAssets();
    super.initState();
  }

  Future<void> _loadCardRiveAssets() async {
    final cardRiveData = await loadRiveButton(
      assetPath: widget.riveAssetPath,
      stateMachineName: widget.riveStateMachineName,
      triggerName: widget.riveTriggerName,
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

      // Sync text bounce with Rive bounce
      setState(() {
        _scale = 0.9;
        _iconScale = 0.9;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _scale = 1.0;
            _iconScale = 1.0;
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onTap();
        }
      });
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
          // Icon/Text on top of the Rive animation/image
          AnimatedScale(
            scale: _iconScale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Center(
              child: Builder(
                builder: (BuildContext context) {
                  switch (widget.gameName) {
                    case 'Alphabet':
                      return Image.asset(
                        'assets/images/alphabet.png',
                        height: 150.0,
                        width: 200.0,
                      );
                    case 'Numbers':
                      return Image.asset(
                        'assets/images/numbers.png',
                        height: 110.0,
                        width: 200.0,
                      );
                    case 'Colors':
                      return Image.asset(
                        'assets/images/art.png',
                        height: 110.0,
                        width: 200.0,
                      );
                    case 'Animals':
                      return Image.asset(
                        'assets/images/animals.png',
                        height: 110.0,
                        width: 200.0,
                      );
                    case 'Shapes':
                      return Image.asset(
                        'assets/images/shapes.png',
                        height: 140.0,
                        width: 200.0,
                      );
                    case 'Memory':
                      return Image.asset(
                        'assets/images/puzzle.png',
                        height: 110.0,
                        width: 200.0,
                      );
                    default:
                      return const Icon(
                        Icons.gamepad,
                        size: 100,
                        color: Colors.white,
                      );
                  }
                },
              ),
            ),
          ),

          Positioned(
            bottom: 15,
            left: 50,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Text(
                widget.gameName,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Luckiest Guy',
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0xFF34732F),
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RiveCard extends StatelessWidget {
  final rive.Artboard? artboard;
  final rive.SMITrigger? trigger;
  final VoidCallback onTap;
  final double width;
  final double height;
  final BoxFit fit;
  const RiveCard({
    super.key,
    required this.artboard,
    required this.trigger,
    required this.onTap,
    this.width = 350,
    this.height = 200,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: artboard != null
              ? rive.Rive(
                  artboard: artboard!,
                  fit: fit,
                  alignment: Alignment.center,
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
