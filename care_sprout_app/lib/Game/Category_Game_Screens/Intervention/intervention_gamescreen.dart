import 'dart:math';

import 'package:care_sprout/Game/Category_Game_Screens/Intervention/intervention_difficulty.dart';
import 'package:care_sprout/Game/Category_Game_Screens/Intervention/mini_game.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class InterventionGamescreen extends StatefulWidget {
  final int level;
  const InterventionGamescreen({super.key, required this.level});

  @override
  State<InterventionGamescreen> createState() => _InterventionGamescreenState();
}

class _InterventionGamescreenState extends State<InterventionGamescreen> {
  static const Map<InterventionGameId, String> _gameBackgrounds = {
    InterventionGameId.brushingTeeth: 'assets/Intervention/bg/bathroom.jpg',
    InterventionGameId.handwashing: 'assets/Intervention/bg/sink.jpg',
    InterventionGameId.gettingDressed: 'assets/Intervention/bg/bedroom.jpg',
    InterventionGameId.shoesMatching: 'assets/Intervention/bg/closet.jpg',
    InterventionGameId.bedMaking: 'assets/Intervention/bg/bedroom.jpg',
    InterventionGameId.healthyEatingPlate: 'assets/Intervention/bg/kitchen.jpg',
    InterventionGameId.bathTime: 'assets/Intervention/bg/bathroom.jpg',
    InterventionGameId.sortingLaundry: 'assets/Intervention/bg/laundry.jpg',
    InterventionGameId.roomCleaning: 'assets/Intervention/bg/room.jpg',
    InterventionGameId.groceryShopping: 'assets/Intervention/bg/grocery.jpg',
    InterventionGameId.crossingStreet: 'assets/Intervention/bg/street.jpg',
    InterventionGameId.moneyMatching: 'assets/Intervention/bg/cashier.jpg',
    InterventionGameId.recyclingSorter: 'assets/Intervention/bg/recycle.jpg',
  };

  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

  late final InterventionDifficulty diff;
  late final List<GameEntry> sequence;
  int index = 0;
  bool _showNext = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    diff = difficultyForLevel(widget.level);

    final rand = Random();
    final pool = List<GameEntry>.from(allInterventionGames)..shuffle(rand);

    sequence = pool.take(min(5, pool.length)).toList();

    _loadRiveAssets();
  }

  void _onMiniGameDone() {
    setState(() => _showNext = true);
  }

  void _next() async {
    if (index < sequence.length - 1) {
      setState(() {
        index++;
        _showNext = false;
      });
    } else {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _loadRiveAssets() async {
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );
    if (!mounted) return;
    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;
    });
  }

  void _onBackTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context, false);
      });
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = sequence[index];
    final bg = _gameBackgrounds[current.id];
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: (bg != null)
                  ? Image.asset(
                      bg,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _GradientFallback(),
                    )
                  : const _GradientFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(children: [
                    if (backArtboard != null)
                      GestureDetector(
                        onTap: _onBackTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: rive.Rive(
                            artboard: backArtboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: _onBackTap,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    const SizedBox(width: 10),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Intervention - Level ${widget.level}',
                              style: const TextStyle(
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
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: buildInterventionMiniGame(
                        id: current.id,
                        diff: diff,
                        onDone: _onMiniGameDone,
                        backgroundAsset: bg,
                        useImages: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showNext)
              Positioned(
                right: 24,
                bottom: 24,
                child: FloatingActionButton(
                  onPressed: _next,
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Simple gradient fallback when a background image is missing
class _GradientFallback extends StatelessWidget {
  const _GradientFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF9CCC65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
