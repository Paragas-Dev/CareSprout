// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings

import 'package:care_sprout/Components/group_tile.dart';
import 'package:care_sprout/Components/user_tile.dart';
import 'package:care_sprout/Helper/chat_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Messaging/chat_message.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      _buildSearchBar(),
                      const SizedBox(height: 8.0),
                      _buildSearchResults(),
                      const SizedBox(height: 8.0),
                      _buildGroupList(),
                      const SizedBox(height: 8.0),
                      _buildConversationsList(),
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

  // search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for users...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFFBF8C33)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFBF8C33)),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  // Search functionality
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
      _searchResults.clear();
    });
  }

  void _performSearch(String query) async {
    try {
      final currentUserID = getCurrentUser()!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get(); // Get all users

      final results = snapshot.docs.where((doc) {
        if (doc.id == currentUserID) return false;

        final parentName = (doc.data()['parentName'] ?? '').toString();
        return parentName.toLowerCase().contains(query.toLowerCase());
      }).map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
    }
  }

  //search results
  Widget _buildSearchResults() {
    if (!_isSearching || _searchResults.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final userData = _searchResults[index];
          final parentName = userData['parentName'] ?? 'Unknown User';
          final userId = userData['uid'];

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFBF8C33),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              parentName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF34732F),
              ),
            ),
            onTap: () {
              _clearSearch();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessage(
                    receiverName: parentName,
                    receiverID: userId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

// list of users except the current user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("Loading.."),
          );
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

  //list of groupchatts
  Widget _buildGroupList() {
    final currentUserID = getCurrentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getUserGroups(currentUserID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("Loading.."),
          );
        }

        List<DocumentSnapshot> groups = snapshot.data!.docs;

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: groups
              .map((groupDoc) => _buildGroupListItem(
                  groupDoc.data() as Map<String, dynamic>, context))
              .toList(),
        );
      },
    );
  }

  // build list of conversations
  Widget _buildConversationsList() {
    final currentUserID = getCurrentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getUserChatRooms(currentUserID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error loading conversations");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("Loading conversations..."),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No conversations yet"),
          );
        }

        List<DocumentSnapshot> chatRooms = snapshot.data!.docs;

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: chatRooms
              .map((chatRoomDoc) =>
                  _buildConversationListItem(chatRoomDoc, context))
              .toList(),
        );
      },
    );
  }

  // build individual conversation list tile
  Widget _buildConversationListItem(
      DocumentSnapshot chatRoomDoc, BuildContext context) {
    final currentUserID = getCurrentUser()!.uid;
    final chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(chatRoomData['participants'] ?? []);
    final lastMessage = chatRoomData['lastMessage'] ?? '';
    final lastMessageTime = chatRoomData['lastMessageTime'] as Timestamp?;
    final unreadMap = chatRoomData['unread'] as Map<String, dynamic>?;
    final bool isUnread =
        unreadMap != null && (unreadMap[currentUserID] ?? false);

    // Find the other participant
    final otherParticipantId = participants.firstWhere(
      (id) => id != currentUserID,
      orElse: () => '',
    );

    if (otherParticipantId.isEmpty) {
      return Container();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherParticipantId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final parentName = userData['parentName'] ?? 'Unknown User';
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFBF8C33),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              parentName,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF34732F),
              ),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
            trailing: lastMessageTime != null
                ? Text(
                    _formatTimestamp(lastMessageTime),
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                : null,
            onTap: () async {
              // Mark as read using the service method
              await _chatService.markAsRead(chatRoomDoc.id, currentUserID);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessage(
                    receiverName: parentName,
                    receiverID: otherParticipantId,
                  ),
                ),
              );
            },
          );
        } else {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('admin')
                .doc(otherParticipantId)
                .get(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                final adminData =
                    adminSnapshot.data!.data() as Map<String, dynamic>;
                final adminName = adminData['name'] ?? 'Unknown Admin';
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFBF8C33),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    adminName,
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: const Color(0xFF34732F),
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: lastMessageTime != null
                      ? Text(
                          _formatTimestamp(lastMessageTime),
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () async {
                    // Mark as read using the service method
                    await _chatService.markAsRead(
                        chatRoomDoc.id, currentUserID);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatMessage(
                          receiverName: adminName,
                          receiverID: otherParticipantId,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFBF8C33),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    'Unknown User',
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: const Color(0xFF34732F),
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: lastMessageTime != null
                      ? Text(
                          _formatTimestamp(lastMessageTime),
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () async {
                    // Mark as read using the service method
                    await _chatService.markAsRead(
                        chatRoomDoc.id, currentUserID);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatMessage(
                          receiverName: 'Unknown User',
                          receiverID: otherParticipantId,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

//build individual group list tile
  Widget _buildGroupListItem(
      Map<String, dynamic> groupData, BuildContext context) {
    return GroupTile(
      groupName: groupData["name"],
      onTap: () {
        // Navigate to group chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMessage(
              receiverName: groupData["name"],
              receiverID: groupData["groupId"],
            ),
          ),
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
