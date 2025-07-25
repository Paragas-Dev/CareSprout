import 'package:care_sprout/Models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get users
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // get user Groups
  Stream<QuerySnapshot> getUserGroups(String userID) {
    return _firestore
        .collection("groupChats")
        .where("members", arrayContains: userID)
        .snapshots();
  }

  // get chat rooms for current user
  Stream<QuerySnapshot> getUserChatRooms(String userID) {
    return _firestore
        .collection("chatRooms")
        .where("participants", arrayContains: userID)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }

  // send messages
  Future<void> sendMessage(String receiverID, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUserID).get();
    final String senderName = userDoc.data() != null &&
            (userDoc.data() as Map<String, dynamic>).containsKey('parentName')
        ? (userDoc.data() as Map<String, dynamic>)['parentName'] as String
        : currentUserEmail;

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      senderName: senderName,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room for the two users (sorted UIDs)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Create or update the chat room with participants and unread tracking
    await _firestore.collection("chatRooms").doc(chatRoomID).set({
      'participants': [currentUserID, receiverID],
      'createdAt': timestamp,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'unread': {
        receiverID: true, // Mark as unread for receiver
        currentUserID: false, // Mark as read for sender
      }
    }, SetOptions(merge: true));

    // add new message to database
    await _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct a chatroom ID for the users (sorted UIDs)
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Mark messages as read for a specific user
  Future<void> markAsRead(String chatRoomID, String userID) async {
    await _firestore.collection("chatRooms").doc(chatRoomID).set({
      'unread': {userID: false}
    }, SetOptions(merge: true));
  }

  //create group chatt
  Future<void> createGroup(
      String groupName, List<String> memberIDs, List<String> adminIDs) async {
    //add new group chat in database
    final groupRef = await _firestore.collection('groupChats').add({
      'name': groupName,
      'members': memberIDs,
      'admins': adminIDs,
      'createdBy': _auth.currentUser!.uid,
      'timestamp': Timestamp.now(),
    });
    await groupRef.update({'groupId': groupRef.id});
  }

  //Sending of messages in group chatt
  Future<void> sendGroupMessage(String groupId, String message) async {
    final currentUser = _auth.currentUser!;
    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final senderName = userDoc.data()?['parentName'] ?? currentUser.displayName;
    await _firestore
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .add({
      'senderID': currentUser.uid,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.now(),
    });
  }

  //get group messages
  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return _firestore
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
