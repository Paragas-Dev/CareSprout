// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:care_sprout/Achievement_Screens/lesson_achievement.dart';
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Lesson_Screens/lesson_home.dart';
import 'package:care_sprout/Messaging/chat_homescreen.dart';
import 'package:care_sprout/Messaging/chat_message.dart';
import 'package:care_sprout/profile.dart';
import 'package:care_sprout/settings.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:care_sprout/Helper/rive_button_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  rive.SMITrigger? lessonClick,
      gameClick,
      menuClick,
      messageClick,
      achievementClick,
      profileClick,
      settingsClick;
  rive.StateMachineController? lessonController,
      gameController,
      menuController,
      messageController,
      achievementController,
      profileController,
      settingsController;
  rive.Artboard? lessonArtboard,
      gameArtboard,
      menuArtboard,
      messageArtboard,
      achievementArtboard,
      profileArtboard,
      settingsArtboard;

  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadRiveAssets();
  }

  void _onLessonTap() {
    if (lessonClick != null) {
      lessonClick!.fire();
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

  void _onGameTap() {
    if (gameClick != null) {
      gameClick!.fire();
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

  void _onMenuTap() {
    if (menuClick != null) {
      menuClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isMenuOpen = true;
          });
        }
      });
    }
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  Future<void> _loadRiveAssets() async {
    final lesson = await loadRiveButton(
      assetPath: 'assets/Rive_Files/lessonbtn.riv',
      stateMachineName: 'Lesson Button',
      triggerName: 'Btn Click',
    );
    final game = await loadRiveButton(
      assetPath: 'assets/Rive_Files/gamebtn.riv',
      stateMachineName: 'Game Button',
      triggerName: 'Btn Click',
    );
    final menu = await loadRiveButton(
      assetPath: 'assets/Rive_Files/menubtn.riv',
      stateMachineName: 'Button Menu',
      triggerName: 'Btn_Click',
    );
    final message = await loadRiveButton(
      assetPath: 'assets/Rive_Files/messagemenubtn.riv',
      stateMachineName: 'Message Menu',
      triggerName: 'Message Click',
    );
    final achievement = await loadRiveButton(
      assetPath: 'assets/Rive_Files/achievementmenubtn.riv',
      stateMachineName: 'Achievement Menu',
      triggerName: 'Achievement Click',
    );
    final profile = await loadRiveButton(
      assetPath: 'assets/Rive_Files/profilemenubtn.riv',
      stateMachineName: 'Profile Menu',
      triggerName: 'Profile Click',
    );
    final settings = await loadRiveButton(
      assetPath: 'assets/Rive_Files/settingsmenubtn.riv',
      stateMachineName: 'Settings Menu',
      triggerName: 'Settings Click',
    );
    setState(() {
      lessonArtboard = lesson.artboard;
      lessonClick = lesson.trigger;
      lessonController = lesson.controller;

      gameArtboard = game.artboard;
      gameClick = game.trigger;
      gameController = game.controller;

      menuArtboard = menu.artboard;
      menuClick = menu.trigger;
      menuController = menu.controller;

      messageArtboard = message.artboard;
      messageClick = message.trigger;
      messageController = message.controller;

      achievementArtboard = achievement.artboard;
      achievementClick = achievement.trigger;
      achievementController = achievement.controller;

      profileArtboard = profile.artboard;
      profileClick = profile.trigger;
      profileController = profile.controller;

      settingsArtboard = settings.artboard;
      settingsClick = settings.trigger;
      settingsController = settings.controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: GestureDetector(
          onTap: () {
            if (_isMenuOpen) {
              _closeMenu();
            }
          },
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/school_front.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 35,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/bg_files/school.png',
                  width: double.infinity,
                  height: 550,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 300,
                child: Image.asset(
                  'assets/images/tree.png',
                  width: 300,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 350,
                child: Image.asset(
                  'assets/images/tree.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 100,
                left: 300,
                right: 0,
                child: Image.asset(
                  'assets/images/tree.png',
                  width: 300,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 350,
                right: 0,
                child: Image.asset(
                  'assets/images/tree.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              if (menuArtboard != null)
                Positioned(
                  top: -30,
                  right: -30,
                  child: GestureDetector(
                    onTap: _onMenuTap,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: rive.Rive(
                        artboard: menuArtboard!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Image.asset(
                      'assets/name.png',
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/board.png',
                            width: 380,
                            height: 250,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/wood.png',
                                  width: 200,
                                  height: 40,
                                  fit: BoxFit.fitWidth,
                                ),
                                ValueListenableBuilder<double>(
                                  valueListenable: FontSizeController.fontSize,
                                  builder: (context, fontSize, child) {
                                    return Text(
                                      'Announcement',
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
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 350,
                            height: 220,
                            padding: const EdgeInsets.only(
                                top: 50.0, left: 16.0, right: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ValueListenableBuilder<double>(
                                valueListenable: FontSizeController.fontSize,
                                builder: (context, fontSize, child) {
                                  return const Row(
                                    children: [
                                      _AnnouncementCard(
                                          text:
                                              'Announcement 1: Lorem ipsum dolor sit amet.'),
                                      SizedBox(width: 12),
                                      _AnnouncementCard(
                                          text:
                                              'Announcement 2: Consectetur adipiscing elit.'),
                                      SizedBox(width: 12),
                                      _AnnouncementCard(
                                          text:
                                              'Announcement 3: Sed do eiusmod tempor incididunt.'),
                                      SizedBox(width: 12),
                                      _AnnouncementCard(
                                          text:
                                              'Announcement 4: More updates coming soon.'),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Lessons button
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: lessonArtboard == null
                            ? const Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                onTap: _onLessonTap,
                                child: rive.Rive(
                                  artboard: lessonArtboard!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                      ),
                      // Games button
                      SizedBox(
                          width: 150,
                          height: 150,
                          child: gameArtboard == null
                              ? const Center(child: CircularProgressIndicator())
                              : GestureDetector(
                                  onTap: _onGameTap,
                                  child: rive.Rive(
                                    artboard: gameArtboard!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                    ],
                  ),
                ],
              ),
              if (_isMenuOpen)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFADDEE0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Menu Title
                        Container(
                          height: 70.0,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB4D078),
                                Color(0xFFBF8C33),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: ValueListenableBuilder<double>(
                              valueListenable: FontSizeController.fontSize,
                              builder: (context, fontSize, child) {
                                return Text(
                                  'MENU',
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
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Rive Buttons
                        _SidebarRiveButton(
                          artboard: messageArtboard,
                          onTap: () {
                            if (messageClick != null) {
                              messageClick!.fire();
                              debugPrint('Button Clicked!');
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ChatHomescreen()),
                                  );
                                }
                              });
                            }
                          },
                        ),
                        _SidebarRiveButton(
                          artboard: achievementArtboard,
                          onTap: () {
                            if (achievementClick != null) {
                              achievementClick!.fire();
                              debugPrint('Button Clicked!');
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LessonAchievement()),
                                  );
                                }
                              });
                            }
                          },
                        ),
                        _SidebarRiveButton(
                          artboard: profileArtboard,
                          onTap: () {
                            if (profileClick != null) {
                              profileClick!.fire();
                              debugPrint('Button Clicked!');
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Profile()),
                                  );
                                }
                              });
                            }
                          },
                        ),
                        _SidebarRiveButton(
                          artboard: settingsArtboard,
                          onTap: () {
                            if (settingsClick != null) {
                              settingsClick!.fire();
                              debugPrint('Button Clicked!');
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Settings()),
                                  );
                                }
                              });
                            } else {
                              debugPrint(
                                  'Settings Button Clicked! settingsClick IS NULL.');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String text;

  const _AnnouncementCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Aleo',
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SidebarRiveButton extends StatelessWidget {
  final rive.Artboard? artboard;
  final VoidCallback onTap;

  const _SidebarRiveButton({
    required this.artboard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: artboard == null
                  ? const Center(child: CircularProgressIndicator())
                  : rive.Rive(
                      artboard: artboard!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
