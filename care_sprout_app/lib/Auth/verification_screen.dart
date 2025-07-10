// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:care_sprout/Auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
    _startEmailVerificationCheck();
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
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        }
      });
    }
  }

  Future<void> _launchEmailApp() async {
    final Uri gmailUri = Uri.parse('https://mail.google.com/');
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app. Please check manually.'),
        ),
      );
    }
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        user = _auth.currentUser;

        if (user != null && user.emailVerified) {
          _timer?.cancel();
          debugPrint('Email verified successfully!');
          _showVerifiedDialog();
        }
      }
    });
  }

  void _showVerifiedDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/verified_logo.png'),
              const SizedBox(height: 20),
              const Text(
                'Email Verified',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Aleo',
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your email address (${widget.email}) was successfully verified.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: Colors.grey, fontFamily: 'Aleo'),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(showApprovalDialog: true),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    backController?.dispose();
    super.dispose();
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
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: backArtboard != null
                    ? GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: rive.Rive(
                            artboard: backArtboard!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.brown.shade200, width: 2.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_outlined,
                                  color: Colors.green, size: 30),
                              const SizedBox(height: 10),
                              const Text(
                                'Email Verification Sent!',
                                style: TextStyle(
                                  fontFamily: 'Luckiest Guy',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0xFFBF8C33),
                              ),
                              const Text(
                                'Please check your email inbox (and spam/junk folder) for a verification link sent to:',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 16, fontFamily: 'Aleo'),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.email,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton.icon(
                                onPressed: _launchEmailApp,
                                icon: const Icon(Icons.mail_outline),
                                label: const Text('Redirect to Email/Gmail'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF488A01),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                'Once verified, you can proceed to login.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade100),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
