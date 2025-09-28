// ignore_for_file: unused_local_variable

import 'package:care_sprout/Components/game_background.dart';
import 'package:care_sprout/Game/Category_Game_Screens/Alphabet/alphabet_game_screen.dart';
import 'package:care_sprout/Game/Category_Game_Screens/Intervention/intervention_gamescreen.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Services/progress_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class LevelSelectScreen extends StatefulWidget {
  final String category;
  const LevelSelectScreen({super.key, required this.category});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedLevel = 1;
  late final int _totalLevels;

  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

  // total levels per category
  final Map<String, int> categoryLevelCounts = {
    'Intervention': 15,
    'Functional Academics': 15,
    'Transitional': 15,
    'Transition Livelihood Program': 15,
    'Alphabet': 26,
    'Numbers': 8,
    'Colors': 6,
    'Animals': 7,
    'Shapes': 5,
    'Memory': 6,
  };

  @override
  void initState() {
    super.initState();

    // 🔹 Force landscape when this screen opens
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _totalLevels = categoryLevelCounts[widget.category] ?? 5;
    _loadUnlockedLevel();
    _loadRiveAssets();
  }

  Future<void> _loadRiveAssets() async {
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;
    });
  }

  Future<void> _loadUnlockedLevel() async {
    final unlocked = await ProgressManager.getUnlockedLevel(widget.category);
    setState(() {
      _unlockedLevel = unlocked;
    });
  }

  Future<void> _openLevel(int levelNumber) async {
    // route to the correct game screen; the game screen should `Navigator.pop(context, true)`
    // when the player finishes the level completely.
    Widget target;
    switch (widget.category) {
      case 'Intervention':
        target = InterventionGamescreen(level: levelNumber);
        break;
      case 'Functional Academics':
        target = const Placeholder();
        break;
      case 'Transitional':
        target = const Placeholder();
        break;
      case 'Transition Livelihood Program':
        target = const Placeholder();
        break;
      case 'Alphabet':
        target =
            AlphabetGameScreen(category: widget.category, level: levelNumber);
        break;
      case 'Numbers':
        target = const Placeholder();
        break;
      case 'Colors':
        target = const Placeholder();
        break;
      case 'Animals':
        target = const Placeholder();
        break;
      case 'Shapes':
        target = const Placeholder();
        break;
      case 'Memory':
        target = const Placeholder();
        break;
      default:
        target = const Placeholder();
        break;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InterventionGamescreen(level: levelNumber)),
    );

    // player finished level fully -> unlock next level if needed
    if (result == true) {
      await ProgressManager.unlockNextLevelIfNeeded(
        widget.category,
        levelNumber,
        _totalLevels,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Level $levelNumber complete — progress saved')),
        );
      }
    }

    await _loadUnlockedLevel();
  }

  void _onBackTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: _onBackTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: rive.Rive(
                            artboard: backArtboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
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
                              widget.category,
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
                  ],
                ),
                const SizedBox(height: 60),
                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _totalLevels,
                    itemBuilder: (context, idx) {
                      final level = idx + 1;
                      final isUnlocked = level <= _unlockedLevel;
                      return LevelCard(
                        category: widget.category,
                        levelNumber: level,
                        isUnlocked: isUnlocked,
                        onTap: () => _openLevel(level),
                        riveAssetPath: 'assets/Rive_Files/gamebox.riv',
                        riveStateMachineName: 'Game Box',
                        riveTriggerName: 'GB Click',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LevelCard extends StatefulWidget {
  final String category;
  final int levelNumber;
  final bool isUnlocked;
  final VoidCallback onTap;
  final String riveAssetPath;
  final String riveStateMachineName;
  final String riveTriggerName;
  const LevelCard({
    super.key,
    required this.category,
    required this.levelNumber,
    required this.isUnlocked,
    required this.onTap,
    required this.riveAssetPath,
    required this.riveStateMachineName,
    required this.riveTriggerName,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> {
  rive.SMITrigger? gbClick;
  rive.StateMachineController? gameBoxController;
  rive.Artboard? gameboxArtboard;
  bool isRiveLoaded = false;
  double _scale = 1.0;

  rive.Artboard? lockArtboard;
  rive.SMIInput<bool>? showLockInput;

  @override
  void initState() {
    _loadCardRiveAssets();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked != oldWidget.isUnlocked) {
      _updateLockState();
    }
  }

  // @override
  // void didUpdateWidget(covariant LevelCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.isUnlocked != widget.isUnlocked) {
  //     // If the unlock state changes, we reset the flag so the animation can play once.
  //     _unlockedAnimationTriggered = false;
  //     if (widget.isUnlocked && !_unlockedAnimationTriggered) {
  //       showLockInput?.value = false;
  //       _unlockedAnimationTriggered = true;
  //     }
  //   }
  // }

  Future<void> _loadCardRiveAssets() async {
    final cardRiveData = await loadRiveButton(
      assetPath: widget.riveAssetPath,
      stateMachineName: widget.riveStateMachineName,
      triggerName: widget.riveTriggerName,
    );

    final lockRiveData = await loadRiveButton(
      assetPath: 'assets/Rive_Files/new_file.riv',
      stateMachineName: 'State Machine 1',
      triggerName: 'Show',
    );

    if (!mounted) return;

    setState(() {
      gameboxArtboard = cardRiveData.artboard;
      gameBoxController = cardRiveData.controller;
      gbClick = cardRiveData.trigger;
      isRiveLoaded = true;

      lockArtboard = lockRiveData.artboard;
      showLockInput = lockRiveData.controller?.findInput<bool>('ShowLock');

      // Call the method to update the lock state
      _updateLockState();
    });
  }

  Future<void> _updateLockState() async {
    if (showLockInput == null) return;

    if (widget.isUnlocked) {
      final alreadyPlayed = await ProgressManager.hasLockAnimationPlayed(
        widget.category,
        widget.levelNumber,
      );

      if (!alreadyPlayed) {
        showLockInput?.value = false;
        await ProgressManager.markLockAnimationPlayed(
          widget.category,
          widget.levelNumber,
        );
      }
    } else {
      showLockInput?.value = true;
    }
  }

  @override
  void dispose() {
    gameBoxController?.dispose();
    super.dispose();
  }

  void _onLevelTap() {
    if (widget.isUnlocked && gbClick != null) {
      AudioService().playClickSound();
      gbClick!.fire();

      setState(() => _scale = 0.9);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _scale = 1.0);
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
      onTap: _onLevelTap,
      child: Opacity(
        opacity: widget.isUnlocked ? 1.0 : 0.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Rive animation
            if (isRiveLoaded)
              Positioned.fill(
                child: rive.Rive(
                  artboard: gameboxArtboard!,
                  fit: BoxFit.cover,
                ),
              )
            else
              // Loading state
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Center(
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: widget.isUnlocked
                    ? Text(
                        '${widget.levelNumber}',
                        style: const TextStyle(
                          fontSize: 80,
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
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Lock Rive animation in the bottom-left corner
            if (!widget.isUnlocked && lockArtboard != null)
              Positioned(
                bottom: -5,
                left: -5,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: rive.Rive(
                    artboard: lockArtboard!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
