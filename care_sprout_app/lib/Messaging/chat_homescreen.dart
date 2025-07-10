import 'package:care_sprout/Components/user_tile.dart';
import 'package:care_sprout/Helper/chat_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Messaging/chat_message.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class ChatHomescreen extends StatefulWidget {
  const ChatHomescreen({super.key});

  @override
  State<ChatHomescreen> createState() => _ChatHomescreenState();
}

class _ChatHomescreenState extends State<ChatHomescreen> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

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
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      });
    }
  }

  final ChatService _chatService = ChatService();

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
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
                                    "Chats",
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
                      const SizedBox(height: 8.0),
                      _buildUserList(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// build list of users except the currently login user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

// build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Display all users except current user
    if (userData["uid"] != getCurrentUser()!.uid) {
      return UserTile(
        text: userData["parentName"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatMessage(
                    receiverName: userData["parentName"],
                    receiverID: userData["uid"])),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
