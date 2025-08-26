// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:care_sprout/Achievement_Screens/lesson_achievement.dart';
import 'package:care_sprout/Components/parent_verification.dart';
import 'package:care_sprout/Components/unlock_content_dialog.dart';
import 'package:care_sprout/Game/game_homescreen.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Lesson_Screens/lesson_home.dart';
import 'package:care_sprout/Messaging/chat_homescreen.dart';
import 'package:care_sprout/profile.dart';
import 'package:care_sprout/settings.dart';
import 'package:care_sprout/Announcement_Screens/announcements_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Helper/guest_helper.dart';

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
      announcementClick,
      achievementClick,
      profileClick,
      okClick,
      settingsClick;
  rive.StateMachineController? lessonController,
      gameController,
      menuController,
      messageController,
      announcementController,
      achievementController,
      profileController,
      okController,
      settingsController;
  rive.Artboard? lessonArtboard,
      gameArtboard,
      menuArtboard,
      messageArtboard,
      announcementArtboard,
      achievementArtboard,
      profileArtboard,
      okArtboard,
      settingsArtboard;

  bool _isMenuOpen = false;
  bool _isGuest = false;
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadRiveAssets();
    _startAutoScroll();
    _checkGuest();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    final announcement = await loadRiveButton(
      assetPath: 'assets/Rive_Files/announcementmenubtn.riv',
      stateMachineName: 'Announcement Menu',
      triggerName: 'Announcement Click',
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
    final ok = await loadRiveButton(
      assetPath: 'assets/Rive_Files/ok_btn.riv',
      stateMachineName: 'Ok Button',
      triggerName: 'Btn Click',
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

      announcementArtboard = announcement.artboard;
      announcementClick = announcement.trigger;
      announcementController = announcement.controller;

      achievementArtboard = achievement.artboard;
      achievementClick = achievement.trigger;
      achievementController = achievement.controller;

      profileArtboard = profile.artboard;
      profileClick = profile.trigger;
      profileController = profile.controller;

      settingsArtboard = settings.artboard;
      settingsClick = settings.trigger;
      settingsController = settings.controller;

      okArtboard = ok.artboard;
      okClick = ok.trigger;
      okController = ok.controller;
    });
  }

  void _checkGuest() async {
    _isGuest = await isGuestUser();
    setState(() {});
  }

  void _showGuestRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Access Restricted'),
        content: const Text('Please sign in to access this feature.'),
        actions: [
          if (okArtboard != null)
            GestureDetector(
              onTap: () {
                if (okClick != null) {
                  AudioService().playClickSound();
                  okClick!.fire();
                  debugPrint('Button Clicked!');
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: rive.Rive(
                  artboard: okArtboard!,
                  fit: BoxFit.fill,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      final pageCount = _pageController.positions.isNotEmpty
          ? _pageController.positions.first.viewportDimension > 0
              ? _pageController.positions.first.maxScrollExtent ~/
                      _pageController.positions.first.viewportDimension +
                  1
              : 0
          : 0;
      if (pageCount == 0) return;
      _currentPage++;
      if (_currentPage >= pageCount) _currentPage = 0;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onLessonTap() async {
    if (lessonClick != null) {
      AudioService().playClickSound();
      lessonClick!.fire();
      debugPrint('Button Clicked!');

      if (_isGuest) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LessonHome()),
          );
        }
        return;
      }

      final bool? isUnlocked = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const UnlockContentDialog(),
      );

      if (isUnlocked == true) {
        if (mounted) {
          final bool? isParentVerified = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const ParentVerification(),
          );

          if (isParentVerified == true) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LessonHome()),
              );
            }
          }
        }
      }
    }
  }

  void _onGameTap() {
    if (gameClick != null) {
      AudioService().playClickSound();
      gameClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameHomescreen()),
          );
        }
      });
    }
  }

  void _onMenuTap() {
    if (menuClick != null) {
      AudioService().playClickSound();
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

  Future<void> _onSidebarButtonTap(
      rive.SMITrigger? trigger, Widget destinationPage) async {
    if (_isGuest) {
      if (destinationPage is Settings) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
        return;
      } else {
        _showGuestRestrictionDialog();
        return;
      }
    }

    if (trigger != null) {
      AudioService().playClickSound();
      trigger.fire();
      debugPrint('Button Clicked!');

      final bool? isUnlocked = await showDialog<bool>(
        context: context,
        builder: (context) => const UnlockContentDialog(),
      );

      if (isUnlocked == true) {
        if (mounted) {
          final bool? isParentVerified = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const ParentVerification(),
          );

          if (isParentVerified == true) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              );
            }
          }
        }
      }
    }
  }

  // Individual button tap functions using the new generic function
  void _onMessageTap() =>
      _onSidebarButtonTap(messageClick, const ChatHomescreen());
  void _onAnnouncementTap() =>
      _onSidebarButtonTap(announcementClick, const AnnouncementsPage());
  void _onAchievementTap() =>
      _onSidebarButtonTap(achievementClick, const LessonAchievement());
  void _onProfileTap() => _onSidebarButtonTap(profileClick, const Profile());
  void _onSettingsTap() => _onSidebarButtonTap(settingsClick, const Settings());

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
                            height: 270,
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
                            height: 240,
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
                            //announcement section
                            child: _isGuest
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 170,
                                        child: Center(
                                          child: Container(
                                            width: 310,
                                            height: 170,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.white30),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Welcome to Care Sprout',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontFamily: 'Luckiest Guy',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: Color(0xFF34732F),
                                                      offset: Offset(2, 2),
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SmoothPageIndicator(
                                        controller: _pageController,
                                        count: 1,
                                        effect: const WormEffect(
                                          dotHeight: 8,
                                          dotWidth: 8,
                                          activeDotColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  )
                                : StreamBuilder<cf.QuerySnapshot>(
                                    stream: cf.FirebaseFirestore.instance
                                        .collection('announcements')
                                        .orderBy('createdAt', descending: true)
                                        .limit(6)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      final docs = snapshot.data!.docs;
                                      if (docs.isEmpty) {
                                        return const Center(
                                          child: Text("No announcement yet."),
                                        );
                                      }
                                      if (_currentPage >= docs.length) {
                                        _currentPage = 0;
                                      }
                                      _startAutoScroll();
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 170,
                                            child: PageView.builder(
                                              controller: _pageController,
                                              itemCount: docs.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      index) {
                                                if (index == docs.length) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AnnouncementsPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 310,
                                                      height: 230,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color:
                                                                Colors.white30),
                                                      ),
                                                      child: const Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .announcement,
                                                              color:
                                                                  Colors.white,
                                                              size: 40,
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Text(
                                                              'View All\nAnnouncements',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Aleo',
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final data = docs[index].data()
                                                    as Map<String, dynamic>;
                                                final title = data['title'] ??
                                                    'Announcement';
                                                final content =
                                                    data['content'] ?? '';
                                                return _AnnouncementCard(
                                                  title: title,
                                                  content: content,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SmoothPageIndicator(
                                            controller: _pageController,
                                            count: docs.length,
                                            effect: const WormEffect(
                                              dotHeight: 8,
                                              dotWidth: 8,
                                              activeDotColor: Colors.green,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
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
                          onTap: _onMessageTap,
                        ),
                        _SidebarRiveButton(
                          artboard: announcementArtboard,
                          onTap: _onAnnouncementTap,
                        ),
                        _SidebarRiveButton(
                          artboard: achievementArtboard,
                          onTap: () {
                            AudioService().playClickSound();
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
                          onTap: _onProfileTap,
                        ),
                        _SidebarRiveButton(
                          artboard: settingsArtboard,
                          onTap: () {
                            AudioService().playClickSound();
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
  final String title;
  final String content;

  const _AnnouncementCard({
    required this.title,
    required this.content,
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
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Aleo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Aleo',
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
        ],
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
