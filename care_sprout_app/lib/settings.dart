import 'package:care_sprout/Auth/login.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:rive/rive.dart' as rive;
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Helper/guest_helper.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  rive.SMITrigger? backClick, logoutClick;
  rive.StateMachineController? backController, logoutController;
  rive.Artboard? backArtboard, logoutArtboard;

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

    final logoutBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/logout.riv',
      stateMachineName: 'Logout Btn',
      triggerName: 'Logout Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      logoutArtboard = logoutBtn.artboard;
      logoutController = logoutBtn.controller;
      logoutClick = logoutBtn.trigger;
    });
  }

  void _onTap() {
    if (backClick != null) {
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

  void _onLogoutTap() async {
    bool isGuest = await isGuestUser();

    if (isGuest) {
      _showGuestWarning();
    } else {
      _logout();
    }
  }

  Future<void> _logout() async {
    if (logoutClick != null) {
      logoutClick!.fire();
      debugPrint('Button Clicked!');

      try {
        await FirebaseAuth.instance.signOut();
        debugPrint('User signed out from Firebase.');

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(showApprovalDialog: false),
          ),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        debugPrint('Error signing out: $e');
      }
    }
  }

  void _showGuestWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
            'Logging out as a guest will erase all your progress.'
            'If you want to keep your progress, please coordinate to the administrator to create an account before logging out.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Container(
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
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  "Settings",
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Music',
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
                        Switch(
                          value: true,
                          onChanged: (value) {
                            if (kDebugMode) {
                              print(value);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Sound',
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
                        Switch(
                          value: true,
                          onChanged: (value) {
                            if (kDebugMode) {
                              print(value);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Font Size',
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
                        Center(
                          child: ValueListenableBuilder<double>(
                            valueListenable: FontSizeController.fontSize,
                            builder: (context, fontSize, child) {
                              return Text(
                                'Make Text Bigger or Smaller',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontFamily: 'Aleo',
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFBF8C33),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Luckiest Guy',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBF8C33),
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder<double>(
                                valueListenable: FontSizeController.fontSize,
                                builder: (context, fontSize, child) {
                                  return Slider(
                                    value: fontSize,
                                    min: 16.0,
                                    max: 30.0,
                                    divisions: 4,
                                    activeColor: const Color(0xFFBF8C33),
                                    inactiveColor: const Color(0xFFB3D981),
                                    onChanged: (value) {
                                      FontSizeController.fontSize.value = value;
                                    },
                                  );
                                },
                              ),
                            ),
                            const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'Luckiest Guy',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBF8C33),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Notification',
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
                        Switch(
                          value: true,
                          onChanged: (value) {
                            if (kDebugMode) {
                              print(value);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Vibration',
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
                        Switch(
                          value: true,
                          onChanged: (value) {
                            if (kDebugMode) {
                              print(value);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: GestureDetector(
                        onTap: _onLogoutTap,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: logoutArtboard == null
                              ? const Center(child: CircularProgressIndicator())
                              : GestureDetector(
                                  child: rive.Rive(
                                    artboard: logoutArtboard!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
