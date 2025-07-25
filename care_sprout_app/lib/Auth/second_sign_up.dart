// ignore_for_file: use_build_context_synchronously

import 'package:care_sprout/Auth/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:rive/rive.dart' as rive;
import 'package:cloud_firestore/cloud_firestore.dart';

class SecondSignUp extends StatefulWidget {
  final String firstName,
      lastName,
      middleName,
      gender,
      birthYear,
      disability,
      homeAddress,
      lrn;
  const SecondSignUp({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.gender,
    required this.birthYear,
    required this.disability,
    required this.homeAddress,
    required this.lrn,
  });

  @override
  State<SecondSignUp> createState() => _SecondSignUpState();
}

class _SecondSignUpState extends State<SecondSignUp> {
  // Rive assets for the buttons
  rive.SMITrigger? backClick, signupBtnClick;
  rive.StateMachineController? backController, signupController;
  rive.Artboard? backArtboard, signupArtboard;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the text fields
  final parentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // validation state
  bool _parentNameError = false;
  bool _phoneError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final _formKey = GlobalKey<FormState>();

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
    final signUpBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/signupbtn.riv',
      stateMachineName: 'sign up',
      triggerName: 'Btn Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      signupArtboard = signUpBtn.artboard;
      signupController = signUpBtn.controller;
      signupBtnClick = signUpBtn.trigger;
    });
  }

  void _onTap() {
    if (backClick != null) {
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _onSignUpTap() async {
    setState(() {
      _parentNameError = parentNameController.text.trim().isEmpty;
      _phoneError = phoneController.text.trim().isEmpty;
      _emailError = emailController.text.trim().isEmpty;
      _passwordError = passwordController.text.trim().isEmpty;
      _confirmPasswordError = confirmPasswordController.text.trim().isEmpty;
    });
    if (_parentNameError ||
        _phoneError ||
        _emailError ||
        _passwordError ||
        _confirmPasswordError) {
      return;
    }
    if (signupBtnClick != null) {
      signupBtnClick!.fire();
      debugPrint('Button Clicked!');
      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        if (password != confirmPasswordController.text.trim()) {
          setState(() {
            _passwordError = true;
            _confirmPasswordError = true;
          });
          return;
        }
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();
          debugPrint('Verification email sent to ${user.email}');

          final userId = user.uid;

          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'uid': userId,
            'userName':
                '${widget.firstName} ${widget.middleName} ${widget.lastName}'
                    .trim(),
            'gender': widget.gender,
            'LRN': widget.lrn,
            'birthYear': widget.birthYear,
            'homeAddress': widget.homeAddress,
            'disability': widget.disability,
            'parentName': parentNameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': email,
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
          });

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => VerificationScreen(
                        email: user.email ?? '',
                      )),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          // Try to sign in with the provided credentials
          try {
            UserCredential userCredential =
                await _auth.signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
            User? user = userCredential.user;
            if (user != null && !user.emailVerified) {
              await user.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Email already registered but not verified. Verification email resent.')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VerificationScreen(email: user.email ?? ''),
                ),
              );
              return;
            } else {
              errorMessage = 'The account already exists for that email.';
            }
          } on FirebaseAuthException catch (signInError) {
            errorMessage = 'The account already exists for that email.';
          }
        } else {
          errorMessage = e.message ?? 'An unknown error occurred.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An unexpected error: $e')));
      }
    }
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
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
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 35.0),
                        CustomTextFieldContainer(
                          labelText: "PARENT'S NAME",
                          controller: parentNameController,
                          error: _parentNameError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Parent's name is required";
                            }
                            return null;
                          },
                        ),
                        CustomTextFieldContainer(
                          labelText: 'PHONE NUMBER',
                          controller: phoneController,
                          error: _phoneError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Phone number is required";
                            }
                            if (!RegExp(r'^(09|\+639)\d{9}')
                                .hasMatch(value.trim())) {
                              return "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),
                        CustomTextFieldContainer(
                          labelText: 'EMAIL',
                          controller: emailController,
                          error: _emailError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required!';
                            } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+')
                                .hasMatch(value)) {
                              return 'Enter a valid email';
                            } else {
                              return null;
                            }
                          },
                        ),
                        CustomTextFieldContainer(
                          labelText: 'PASSWORD',
                          controller: passwordController,
                          error: _passwordError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            } else {
                              return null;
                            }
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          obscureText: !_showPassword,
                        ),
                        CustomTextFieldContainer(
                          labelText: 'CONFIRM PASSWORD',
                          controller: confirmPasswordController,
                          error: _confirmPasswordError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Confirm your password";
                            }
                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                          obscureText: !_showConfirmPassword,
                        ),
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 90,
                            child: signupArtboard == null
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _parentNameError = parentNameController
                                            .text
                                            .trim()
                                            .isEmpty;
                                        _phoneError =
                                            phoneController.text.trim().isEmpty;
                                        _emailError =
                                            emailController.text.trim().isEmpty;
                                        _passwordError = passwordController.text
                                            .trim()
                                            .isEmpty;
                                        _confirmPasswordError =
                                            confirmPasswordController.text
                                                .trim()
                                                .isEmpty;
                                      });
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        _onSignUpTap();
                                      }
                                    },
                                    child: rive.Rive(
                                        artboard: signupArtboard!,
                                        fit: BoxFit.contain),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextFieldContainer extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final bool error;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextFieldContainer({
    super.key,
    required this.labelText,
    this.controller,
    this.error = false,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: const TextStyle(
              fontFamily: 'Luckiest Guy',
              fontWeight: FontWeight.bold,
              color: Color(0xFF488A01),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB3D981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
