// ignore_for_file: deprecated_member_use

import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Lesson_Screens/lesson_home.dart';
import 'package:care_sprout/Lesson_Screens/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  var backBtn = 'assets/Rive_Files/backarrow.riv';

  rive.SMITrigger? buttonClick;
  rive.StateMachineController? buttonController;
  rive.Artboard? artboard;

  @override
  void initState() {
    rootBundle.load(backBtn).then((value) async {
      await rive.RiveFile.initialize();
      final file = rive.RiveFile.import(value);
      final back = file.mainArtboard;
      buttonController =
          rive.StateMachineController.fromArtboard(back, 'backArrow');
      if (buttonController != null) {
        back.addController(buttonController!);
        buttonController!.inputs.forEach((element) {
          if (element.name == "btn Click") {
            buttonClick = element as rive.SMITrigger;
          }
        });
      }
      setState(() {
        artboard = back;
      });
    });
    super.initState();
  }

  void _onTap() {
    if (buttonClick != null) {
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LessonHome()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (artboard != null)
                        GestureDetector(
                          onTap: _onTap,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: rive.Rive(
                              artboard: artboard!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const SizedBox(width: 40.0),
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
                          child: ValueListenableBuilder<double>(
                            valueListenable: FontSizeController.fontSize,
                            builder: (context, fontSize, child) {
                              return Text(
                                'Lesson Title',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontFamily: 'Aleo',
                                  letterSpacing: 1.5,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFF34732F),
                                      offset: Offset(2, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            },
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
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      LessonCard(
                        fileName: "Lesson 1: Introduction to Lines",
                        progress: 0.15,
                        showComment: false,
                        showProgress: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LessonScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LessonCard(
                        fileName: "Lesson 2: Introduction to Alphabet",
                        progress: 0.0,
                        showComment: false,
                        showProgress: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LessonScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String fileName;
  final double progress;
  final bool showComment;
  final bool showProgress;
  final VoidCallback? onTap;

  const LessonCard(
      {super.key,
      required this.fileName,
      required this.progress,
      this.showProgress = true,
      this.showComment = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB3D981),
              Color(0xFFBF8C33),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: FontSizeController.fontSize,
                builder: (context, fontSize, child) {
                  return Text(
                    fileName,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Aleo',
                      letterSpacing: 1.5,
                      shadows: const [
                        Shadow(
                          color: Color(0xFF34732F),
                          offset: Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ],
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
              ),
              const SizedBox(height: 20),
              showProgress
                  ? Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFAADDE0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFBF8C33)),
                          minHeight: 18,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              "${(progress * 100).toInt()}%",
                              style: const TextStyle(
                                color: Color(0xFFBF8C33),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(height: 18),
              if (showComment) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Add class comment",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(color: Color(0xFFBF8C33)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF8C33),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
