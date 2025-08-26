import 'package:care_sprout/Helper/audio_service.dart';
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

  //instances for the Messages
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
    AudioService().pauseBgMusic();
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
      AudioService().playClickSound();
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
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      await AudioService().playMessageSent();

      //clear text controller
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    AudioService().resumeBgMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFCBE9DF),
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
                            width: 30,
                            height: 30,
                            child: rive.Rive(
                              artboard: backArtboard!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 30.0,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                        widget.receiverName,
                        style: const TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'Aleo',
                            fontWeight: FontWeight.w400),
                      ),
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

    final isCurrentUser =
        data['senderID'] == FirebaseAuth.instance.currentUser!.uid;

    //alignment/Color/Bubble Style of the messages
    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isCurrentUser ? const Color(0xFFBF8C33) : const Color(0xFFB4D078);
    const textColor = Colors.white;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            data['senderName'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12.0,
              fontFamily: 'Aleo',
              fontWeight:
                  data['senderID'] == FirebaseAuth.instance.currentUser!.uid
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    isCurrentUser ? const Radius.circular(12) : Radius.zero,
                bottomRight:
                    isCurrentUser ? Radius.zero : const Radius.circular(12),
              ),
            ),
            child: Text(
              data['message'],
              style: const TextStyle(
                  color: textColor,
                  fontSize: 15.0,
                  fontFamily: 'Aleo',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: sendMessage,
            child: IconButton(
              onPressed: sendMessage,
              icon: Image.asset(
                "assets/images/sendBtn.png",
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
