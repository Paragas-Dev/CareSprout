import 'package:care_sprout/Helper/chat_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Messaging/chat_homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class ChatMessage extends StatefulWidget {
  final String receiverName;
  final String receiverID;
  const ChatMessage({
    super.key,
    required this.receiverName,
    required this.receiverID,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;
  bool showLessons = true;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

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
            MaterialPageRoute(builder: (context) => const ChatHomescreen()),
            (route) => false,
          );
        }
      });
    }
  }

  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      //send the message
      await _chatService.sendMesage(widget.receiverID, _messageController.text);

      //clear text controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFCBE9DF),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFB4D078),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
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
                      Text(widget.receiverName),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Messages List
              Expanded(
                child: _buildMesageList(),
              ),
              // Input Field
              _buildUserInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMesageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("Loading.."),
          );
        }

        //return ListView
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Text(data["message"]);
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "Type a message",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        GestureDetector(
          onTap: sendMessage,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFBF8C33),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
