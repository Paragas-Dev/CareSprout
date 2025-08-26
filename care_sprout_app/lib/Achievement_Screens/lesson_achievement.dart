import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rive/rive.dart' as rive;

class LessonAchievement extends StatefulWidget {
  const LessonAchievement({super.key});

  @override
  State<LessonAchievement> createState() => _LessonAchievementState();
}

class _LessonAchievementState extends State<LessonAchievement> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;
  bool showLessons = true;

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
    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;
    });
  }

  void _onTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    if (backArtboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 40,
                          height: 40,
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
                              "Achievement",
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
                const SizedBox(height: 8.0),
                const Divider(
                  thickness: 3,
                  color: Color(0xFFBF8C33),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: showLessons
                            ? const Color(0xFFBF8C33)
                            : const Color(0xFFEBF3DE),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showLessons = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Lesson',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Luckiest Guy',
                              color: showLessons
                                  ? Colors.white
                                  : const Color(0xFFBF8C33),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: !showLessons
                            ? const Color(0xFFBF8C33)
                            : const Color(0xFFEBF3DE),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showLessons = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Games',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Luckiest Guy',
                              color: !showLessons
                                  ? Colors.white
                                  : const Color(0xFFBF8C33),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSize,
                      builder: (context, fontSize, child) {
                        return Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontFamily: 'Luckiest Guy',
                            letterSpacing: 1.5,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (showLessons)
                  Center(
                    child: Wrap(
                      spacing: 60.0,
                      runSpacing: 30.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCircularIndicator(
                          title: "Alphabet",
                          percent: 0.60,
                          progressColor: const Color(0xFF8E44AD),
                        ),
                        _buildCircularIndicator(
                          title: "Shapes",
                          percent: 0.50,
                          progressColor: const Color(0xFFF1C40F), // Yellow
                        ),
                        _buildCircularIndicator(
                          title: "Rhymes",
                          percent: 0.80,
                          progressColor: const Color(0xFFE74C3C), // Pink
                        ),
                        _buildCircularIndicator(
                          title: "Stories",
                          percent: 0.30,
                          progressColor: const Color(0xFF3498DB), // Blue
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Wrap(
                      spacing: 60.0,
                      runSpacing: 30.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCircularIndicator(
                          title: "Puzzle",
                          percent: 0.40,
                          progressColor: const Color(0xFF2ECC71), // Green
                        ),
                        _buildCircularIndicator(
                          title: "Quiz",
                          percent: 0.70,
                          progressColor: const Color(0xFF9B59B6), // Purple
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

Widget _buildCircularIndicator({
  required String title,
  required double percent,
  required Color progressColor,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularPercentIndicator(
        radius: 60.0,
        lineWidth: 10.0,
        percent: percent,
        animation: true,
        animationDuration: 1000,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: progressColor,
        backgroundColor: const Color(0xFFE0E0E0),
        center: Text(
          "${(percent * 100).toInt()}%",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Luckiest Guy',
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 8.0),
      ValueListenableBuilder<double>(
        valueListenable: FontSizeController.fontSize,
        builder: (context, fontSize, child) {
          return Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Luckiest Guy',
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          );
        },
      ),
    ],
  );
}
