// ignore_for_file: use_build_context_synchronously

import 'package:care_sprout/Auth/sign_up.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_popup_window_widget/on_popup_window_widget.dart';
import 'package:rive/rive.dart' as rive;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  final bool showApprovalDialog;
  const Login({super.key, this.showApprovalDialog = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Rive assets for the sign-in button
  var riveUrl = 'assets/Rive_Files/sign_in.riv';
  rive.SMITrigger? buttonClick;
  rive.StateMachineController? buttonController;
  rive.Artboard? artboard;

  // Controllers for the text fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    rootBundle.load(riveUrl).then((value) async {
      await rive.RiveFile.initialize();
      final file = rive.RiveFile.import(value);
      final signIn = file.mainArtboard;
      buttonController =
          rive.StateMachineController.fromArtboard(signIn, 'sign in');
      if (buttonController != null) {
        signIn.addController(buttonController!);
        buttonController!.inputs.forEach((element) {
          if (element.name == "Btn Click") {
            buttonClick = element as rive.SMITrigger;
          }
        });
      }
      setState(() {
        artboard = signIn;
      });
    });

    //Approval checking widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        _checkApprovalStatusAndNavigate();
      } else if (widget.showApprovalDialog) {
        _showApprovalDialog();
      }
    });
  }

  //check if the user is in approval when open the app again
  Future<void> _checkApprovalStatusAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.isAnonymous) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        return;
      }
      final userDoc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final status = userDoc.data()?['status'] ?? 'pending';
      if (status != 'approved' && mounted) {
        _showApprovalDialog();
      } else if (status == 'approved' && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  //Guest Login
  void _onGuestLogin() async {
    try {
      final UserCredential = await FirebaseAuth.instance.signInAnonymously();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGuest', true);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in as guest: $e')),
      );
    }
  }

  //Sign Up logic
  void _onSignInTap() async {
    if (_formKey.currentState?.validate() != true) return;
    if (buttonClick != null) {
      buttonClick!.fire();
      debugPrint('Button Clicked!');

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")),
        );
        return;
      }

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDoc = await firestore.FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final status = userDoc.data()?['status'] ?? 'pending';
          if (status != 'approved' && mounted) {
            _showApprovalDialog();
          } else if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed';
        if (e.code == 'user-not-found') {
          message = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        } else {
          message = e.message ?? 'Unknown error';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  //Approval Dialog
  void _showApprovalDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 300,
                height: 300,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                textAlign: TextAlign.center,
                                "Waiting \n for \n Approval",
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  //forgot password logic
  Future<void> _forgotPassword() async {
    TextEditingController resetEmailController = TextEditingController();

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Material(
          type: MaterialType.transparency,
          child: OnPopupWindowWidget.widgetMode(
              title: const Text("Reset Password"),
              footer: ElevatedButton(
                onPressed: () async {
                  String email = resetEmailController.text.trim();
                  if (email.isNotEmpty) {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Send"),
              ),
              overlapChildren: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
              child: TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/name.png',
                      width: 200,
                      height: 200,
                    ),
                    const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontFamily: 'Luckiest Guy',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF488A01),
                      ),
                    ),
                    // Email Field
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'EMAIL',
                        style: TextStyle(
                          fontFamily: 'Luckiest Guy',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF488A01),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFB3D981), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontFamily: 'Luckiest Guy',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF488A01),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFB3D981), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Forgot Password

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _forgotPassword,
                        child: const Text(
                          'Forgot password',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sign In Button

                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: artboard == null
                            ? const Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                onTap: _onSignInTap,
                                child: rive.Rive(
                                    artboard: artboard!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Expanded(
                            child: Divider(
                          color: Color(0xFFBF8C33),
                          thickness: 3,
                        )),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('or',
                              style: TextStyle(
                                color: Color(0xFF488A01),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              )),
                        ),
                        Expanded(
                            child: Divider(
                          color: Color(0xFFBF8C33),
                          thickness: 3,
                        )),
                      ],
                    ),
                    // Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Color(0xFF488A01),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: _onGuestLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFBF8C33), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: Color(0xFF488A01),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
