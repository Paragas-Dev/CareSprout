import 'package:care_sprout/Auth/login.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Services/progress_manager.dart';
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

  // Added a ValueNotifier for the tutorial toggle
  final ValueNotifier<bool> tutorialEnabled = ValueNotifier(true);

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
  }

  @override
  void dispose() {
    backController?.dispose();
    logoutController?.dispose();
    tutorialEnabled.dispose();
    super.dispose();
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

  // resetting player progress
  void _onResetProgressTap() {
    AudioService().playClickSound();
    _showResetProgressWarning();
  }

  void _onLogoutTap() async {
    bool isGuest = await isGuestUser();

    if (isGuest) {
      _showGuestWarning();
    } else {
      _logout(isGuest: false);
    }
  }

  Future<void> _logout({bool isGuest = false}) async {
    if (logoutClick != null) {
      await AudioService().playClickSound();
      logoutClick!.fire();
      debugPrint('Button Clicked!');

      try {
        if (isGuest) {
          await FirebaseAuth.instance.currentUser?.delete();
          debugPrint('Guest user deleted.');
        } else {
          await FirebaseAuth.instance.signOut();
          debugPrint('User signed out.');
        }

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

  // warning dialog for resetting progress
  void _showResetProgressWarning() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'Are you sure you want to reset all your game progress? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); 
              // wait until after the dialog is closed to show snackbar
              await Future.delayed(const Duration(milliseconds: 200));

              try {
                await ProgressManager.resetProgress();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All progress has been reset!'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error resetting progress: $e'),
                  ),
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
              _logout(isGuest: true);
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
                        ValueListenableBuilder<bool>(
                          valueListenable: AudioService().musicEnabled,
                          builder: (context, isEnabled, child) {
                            return Switch(
                              value: isEnabled,
                              onChanged: (value) {
                                AudioService().toggleMusic(value);
                              },
                            );
                          },
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
                        ValueListenableBuilder<bool>(
                          valueListenable: AudioService().soundEnabled,
                          builder: (context, isEnabled, child) {
                            return Switch(
                              value: isEnabled,
                              onChanged: (value) {
                                AudioService().toggleSound(value);
                              },
                            );
                          },
                        ),
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color(0xFFBF8C33), // Text color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _onResetProgressTap,
                        child: ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSize,
                          builder: (context, fontSize, child) {
                            return Text(
                              'Reset Progress',
                              style: TextStyle(
                                fontSize: fontSize * 0.75,
                                fontFamily: 'Luckiest Guy',
                                letterSpacing: 1.2,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF34732F),
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
