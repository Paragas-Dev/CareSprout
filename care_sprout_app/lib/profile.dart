// ignore_for_file: use_build_context_synchronously

import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:on_popup_window_widget/on_popup_window_widget.dart';
import 'package:rive/rive.dart' as rive;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  rive.SMITrigger? backClick, editProfileClick;
  rive.StateMachineController? backController, editProfileController;
  rive.Artboard? backArtboard, editProfileArtboard;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = '';
  String birthYear = '';
  String homeAddress = '';
  String learnerType = '';
  String lrn = '';
  String parentName = '';
  String phone = '';
  String email = '';

  String _selectedAvatar = 'assets/avatars/default_avatar.jpg';

  @override
  void initState() {
    _loadRiveAssets();
    _fetchUserData();
    _loadAvatar();
    super.initState();
  }

  void _loadAvatar() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data.containsKey('avatarPath')) {
        setState(() {
          _selectedAvatar =
              data['avatarPath'];
        });
      }
    }
  }

  Future<void> _loadRiveAssets() async {
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );
    final editProfileBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/profileedit.riv',
      stateMachineName: 'Edit Profile',
      triggerName: 'Btn Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      editProfileArtboard = editProfileBtn.artboard;
      editProfileController = editProfileBtn.controller;
      editProfileClick = editProfileBtn.trigger;
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

  void _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userName = data['userName']?.toString() ?? '';
          birthYear = data['birthYear']?.toString() ?? '';
          homeAddress = data['homeAddress']?.toString() ?? '';
          learnerType = data['disability']?.toString() ?? '';
          lrn = data['LRN']?.toString() ?? '';
          parentName = data['parentName']?.toString() ?? '';
          phone = data['phone']?.toString() ?? '';
          email = data['email']?.toString() ?? '';
        });
      }
    }
  }

  void _onEditTap() {
    if (editProfileClick != null) {
      editProfileClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 300), () {
        _showEditDialog();
      });
    }
  }

  void _showAvatarPicker() {
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: screenHeight * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Choose Your Avatar',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final avatarPath =
                          'assets/avatars/avatar${index + 1}.png';
                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            _selectedAvatar = avatarPath;
                          });
                          final user = _auth.currentUser;
                          if (user != null) {
                            await _firestore
                                .collection('users')
                                .doc(user.uid)
                                .update({
                              'avatarPath': avatarPath,
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 48.0,
                          backgroundImage: AssetImage(avatarPath),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: userName);
    final birthdateCtrl = TextEditingController(text: birthYear);
    final addressCtrl = TextEditingController(text: homeAddress);
    final learnerTypeCtrl = TextEditingController(text: learnerType);
    final lrnCtrl = TextEditingController(text: lrn);
    final guardianNameCtrl = TextEditingController(text: parentName);
    final contactCtrl = TextEditingController(text: phone);
    final emailCtrl = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Material(
          type: MaterialType.transparency,
          child: OnPopupWindowWidget.widgetMode(
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            footer: ElevatedButton(
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    'userName': nameCtrl.text,
                    'birthYear': birthdateCtrl.text,
                    'homeAddress': addressCtrl.text,
                    'disability': learnerTypeCtrl.text,
                    'LRN': lrnCtrl.text,
                    'parentName': guardianNameCtrl.text,
                    'phone': contactCtrl.text,
                    'email': emailCtrl.text,
                  });
                  Navigator.pop(context);
                  _fetchUserData();
                }
              },
              child: const Text('Save'),
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
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('Name', nameCtrl),
                  _buildTextField('Birthdate', birthdateCtrl),
                  _buildTextField('Address', addressCtrl),
                  _buildTextField('Learner Type', learnerTypeCtrl),
                  _buildTextField('LRN', lrnCtrl),
                  _buildTextField('Guardian Name', guardianNameCtrl),
                  _buildTextField('Contact', contactCtrl),
                  _buildTextField('Email', emailCtrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
                    if (backArtboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
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
                              "Profile",
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
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48.0,
                            backgroundImage: AssetImage(_selectedAvatar),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/photoAdd.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSize,
                      builder: (context, fontSize, child) {
                        return Text(
                          'Student Name',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontFamily: 'Aleo',
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                )),
                const SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: editProfileArtboard == null
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTap: _onEditTap,
                            child: rive.Rive(
                              artboard: editProfileArtboard!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(label: 'Birthdate:', value: birthYear),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(
                    label: 'Home Address:', value: homeAddress),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(
                    label: 'Type of Learner:', value: learnerType),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(label: 'LRN:', value: lrn),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(
                    label: 'Guardian\'s Name:', value: parentName),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(
                    label: 'Contact Number:', value: phone),
                const SizedBox(height: 16.0),
                ReactiveTextFieldDisplay(label: 'Email:', value: email),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class ReactiveTextFieldDisplay extends StatelessWidget {
  final String label;
  final String value;

  const ReactiveTextFieldDisplay({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReactiveText(
          text: label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFBF8C33), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSize,
            builder: (context, fontSize, child) {
              return Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'Aleo',
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReactiveText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color color;
  final FontWeight fontWeight;

  const ReactiveText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.color = Colors.black,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: FontSizeController.fontSize,
      builder: (context, fontSize, child) {
        return Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Aleo',
            letterSpacing: 1.5,
            fontWeight: fontWeight,
            color: color,
          ),
        );
      },
    );
  }
}
