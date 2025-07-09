// ignore_for_file: unnecessary_const, deprecated_member_use

import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Lesson_Screens/join_class.dart';
import 'package:care_sprout/Lesson_Screens/subject_screen.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class LessonHome extends StatefulWidget {
  const LessonHome({super.key});

  @override
  State<LessonHome> createState() => _LessonHomeState();
}

class _LessonHomeState extends State<LessonHome> {
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
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                "Lessons",
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
                  Center(
                    child: Column(
                      children: [
                        _LessonProgressCard(
                          title: "LETTERS",
                          color: const Color(0xFFB3D981),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SubjectScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFBF8C33),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        'Join Class',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinClass(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _LessonProgressCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _LessonProgressCard({
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/LessonCard.png'),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.circular(5),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSize,
                      builder: (context, fontSize, child) {
                        return Text(
                          title,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontFamily: 'Luckiest Guy',
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      // Handle menu actions here
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'unenroll',
                        child: Text('Unenroll'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
