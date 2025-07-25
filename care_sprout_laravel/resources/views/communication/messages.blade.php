<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>
  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/messages.css') }}">

</head>
<body style="display: flex; min-height: 100vh; margin: 0;">
  @include('partials.sidebar')
  <div class="main-content-wrapper">
    <div style="width: 100%;">
      @include('partials.header')
      <div class="hamburger-menu" onclick="toggleSidebar(this)">
          <i class="fas fa-bars"></i>
      </div>
    </div>
    <div class="main-content">
      <div class="chat-container">
        <div class="chat-area">
          <div class="chat-header">
            <i class="fas fa-ellipsis-h"></i>
          </div>
          <div class="chat-fade-top"></div>
          <div class="chat-messages">
            <div class="chat-message parent-message">
            </div>
            <div class="chat-message user-message">
            </div>
          </div>
          <div class="reply-section">
            <input
              type="text"
              id="replyInput"
              placeholder="Reply..."
            />
            <button onclick="sendReply()" title="Send">
              <i class="fas fa-paper-plane"></i>
            </button>
          </div>
        </div>
        <div class="list-area">
          <div class="list-header" style="display: flex; justify-content: space-between; align-items: center;">
            <span>Chats</span>
            <i class="fas fa-pen-to-square" style="cursor: pointer;" title="Create New Chat"></i>
          </div>
          <div class="list-search">
            <i class="fas fa-search"></i>
            <input type="text" placeholder="Search" />
          </div>
          <div class="list-items">
            <div class="list-item" onclick="loadChat('Parent Name 1')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Parent Name</div>
                <div class="parent-name">Student Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
            <div class="list-item" onclick="loadChat('Parent Name 2')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Parent Name</div>
                <div class="parent-name">Student Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
            <div class="list-item" onclick="loadChat('Parent Name 3')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Parent Name</div>
                <div class="parent-name">Student Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Centralized Firebase Configuration -->
  <script src="{{ asset('js/firebase-config.js') }}"></script>
  <script>
    function toggleDropdown(element) {
      element.classList.toggle("active");
    }

    document.addEventListener("click", function(event) {
      const drop = document.querySelector(".drop");
      if (drop && !drop.contains(event.target)) {
        drop.classList.remove("active");
      }
    });

    function loadChat(parentName) {
      document.querySelector('.chat-area .chat-header').textContent = `Chats with ${parentName}`;
      const messages = {
        "Parent Name 1": [
          { sender: "parent", text: "Hello!" },
          { sender: "user", text: "Hi! How can I help?" }
        ],
        "Parent Name 2": [
          { sender: "parent", text: "My child is sick." },
          { sender: "user", text: "We'll check on them today." }
        ],
        "Parent Name 3": [
          { sender: "parent", text: "Thank you for the update!" },
          { sender: "user", text: "You're welcome!" }
        ]
      };

      const chatMessages = document.querySelector('.chat-messages');
      chatMessages.innerHTML = '';

      messages[parentName].forEach(msg => {
        const msgEl = document.createElement('div');
        msgEl.classList.add('chat-message', msg.sender === 'user' ? 'user-message' : 'parent-message');
        msgEl.innerHTML = `<p><strong>${msg.sender === 'user' ? 'You' : 'Parent'}:</strong> ${msg.text}</p>`;
        chatMessages.appendChild(msgEl);
      });
    }

    // New function to load chat from Firestore
    function loadChatFromFirestore(parentIdOrGroupId, isGroup) {
      try {
        // Track current chat
        currentChatId = parentIdOrGroupId;
        currentIsGroup = isGroup;

        const chatHeader = document.querySelector('.chat-area .chat-header');
        if (!chatHeader) return;

        const db = window.db;
        if (!db) return;

        if (isGroup) {
          // Fetch the group name if it's a group chat
          db.collection('groupChats').doc(parentIdOrGroupId).get().then(doc => {
            if (doc.exists) {
              const groupData = doc.data();
              const groupName = groupData.groupName || 'Group Chat';
              chatHeader.textContent = `${groupName}`;
            } else {
              chatHeader.textContent = `${parentIdOrGroupId}`;
            }
          }).catch(error => {
            console.log("Error fetching group data:", error);
            chatHeader.textContent = `${parentIdOrGroupId}`;
          });
        } else {
          // Fetch the user's parentName from Firestore
          db.collection('users').doc(parentIdOrGroupId).get().then(doc => {
            if (doc.exists) {
              const userData = doc.data();
              const parentName = userData.parentName || parentIdOrGroupId;
              chatHeader.textContent = `${parentName}`;
            } else {
              chatHeader.textContent = `${parentIdOrGroupId}`;
            }
          }).catch(error => {
            chatHeader.textContent = `${parentIdOrGroupId}`;
          });
        }

        const adminId = window.auth.currentUser.uid;
        const userId = parentIdOrGroupId;
        const chatRoomId = getChatRoomId(adminId, userId);

        const chatMessages = document.querySelector('.chat-messages');
        if (!chatMessages) return;

        chatMessages.innerHTML = '';

        db.collection('chatRooms').doc(chatRoomId).collection('messages').orderBy('createdAt')
          .get().then(snapshot => {
            snapshot.forEach(doc => {
              const msg = doc.data();
              const msgEl = document.createElement('div');
              msgEl.classList.add('chat-message', msg.sender === 'admin' ? 'user-message' : 'parent-message');
              msgEl.innerHTML = `<p><strong>${msg.senderName || msg.sender}:</strong> ${msg.text}</p>`;
              chatMessages.appendChild(msgEl);
            });
            chatMessages.scrollTop = chatMessages.scrollHeight;
          }).catch(error => {
            console.log("Error loading messages:", error);
          });
      } catch (error) {
        console.log("loadChatFromFirestore error:", error);
      }
    }

    function sendReply() {
      const input = document.getElementById('replyInput');
      const message = input.value.trim();

      if (message !== "" && currentChatId) {
        // Send message to Firestore
        sendMessageToFirestore(message, currentChatId, currentIsGroup);

        // Clear input
        input.value = '';
      } else if (message !== "") {
        // Fallback for when no chat is selected
        const chatMessages = document.querySelector('.chat-messages');
        const reply = document.createElement('div');
        reply.classList.add('chat-message', 'user-message');
        reply.innerHTML = `<p><strong>You:</strong> ${message}</p>`;
        chatMessages.appendChild(reply);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        input.value = '';
      }
    }

    // New function to send message to Firestore
    function sendMessageToFirestore(message, chatId, isGroup) {
      try {
        const db = window.db;
        if (!db) {
          console.log("Firebase database not available");
          return;
        }

        const auth = window.auth;
        if (!auth || !auth.currentUser) {
          console.log("User not authenticated");
          return;
        }

        const adminId = window.auth.currentUser.uid;
        const userId = chatId;
        const chatRoomId = getChatRoomId(adminId, userId);

        db.collection('chatRooms').doc(chatRoomId).get().then(doc => {
          if (!doc.exists) {
            // Create new chat room with both admin and user as participants
            db.collection('chatRooms').doc(chatRoomId).set({
              participants: [adminId, userId],
              createdAt: firebase.firestore.FieldValue.serverTimestamp(),
              type: 'individual'
            }, { merge: true })
            .then(() => sendAdminMessageToChatRoom(userId))
            .catch(error => reject(error));
          } else {
            sendAdminMessageToChatRoom(userId);
          }
        }).catch(error => reject(error));

        function sendAdminMessageToChatRoom(userId) {
          const now = new Date();
          const adminId = window.auth.currentUser.uid;
          const chatRoomId = getChatRoomId(adminId, userId);
          db.collection('chatRooms').doc(chatRoomId).collection('messages').add({
            text: message,
            sender: 'admin',
            senderName: 'Admin',
            createdAt: now
          })
          .then(() => {
            document.getElementById('replyInput').value = '';
          })
          .catch(error => reject(error));
        }
      } catch (error) {
        console.log("sendMessageToFirestore error:", error);
      }
    }

    // Global variables to track current chat
    let currentChatId = null;
    let currentIsGroup = false;

    // Function to create chat room if it doesn't exist
    function createChatRoomIfNeeded(chatId, isGroup) {
      return new Promise((resolve, reject) => {
        const db = window.db;
        if (!db) {
          reject("Firebase database not available");
          return;
        }

        const auth = window.auth;
        if (!auth || !auth.currentUser) {
          reject("User not authenticated");
          return;
        }

        const adminId = window.auth.currentUser.uid;
        const userId = chatId;
        const chatRoomId = getChatRoomId(adminId, userId);

        if (isGroup) {
          // For group chats, use the group ID directly
          db.collection('groupChats').doc(chatId).get().then(doc => {
            if (!doc.exists) {
              // Create new group chat room
              const chatRoomData = {
                createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                members: [chatId], // For group chats, just the group ID
                type: 'group'
              };

              db.collection('groupChats').doc(chatId).set(chatRoomData)
                .then(() => {
                  console.log("Group chat room created successfully");
                  resolve();
                })
                .catch(error => {
                  console.log("Error creating group chat room:", error);
                  reject(error);
                });
            } else {
              resolve();
            }
          }).catch(error => {
            console.log("Error checking group chat room:", error);
            reject(error);
          });
        } else {
          // For individual chats, create chat room ID using sorted user IDs
          db.collection('chatRooms').doc(chatRoomId).get().then(doc => {
            if (!doc.exists) {
              // Create new individual chat room
              const chatRoomData = {
                createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                participants: [adminId, userId],
                type: 'individual'
              };

              db.collection('chatRooms').doc(chatRoomId).set(chatRoomData)
                .then(() => {
                  console.log("Individual chat room created successfully");
                  resolve();
                })
                .catch(error => {
                  console.log("Error creating individual chat room:", error);
                  reject(error);
                });
            } else {
              resolve();
            }
          }).catch(error => {
            console.log("Error checking individual chat room:", error);
            reject(error);
          });
        }
      });
    }

    function goTo(url) {
      window.location.href = url;
    }

   function toggleSidebar(element) {
  const sidebar = document.querySelector('.sidebar');
  sidebar.classList.toggle('open');

  // Toggle the icon between bars and times
  const icon = element.querySelector('i');
  if (sidebar.classList.contains('open')) {
    icon.classList.remove('fa-bars');
    icon.classList.add('fa-times');
  } else {
    icon.classList.remove('fa-times');
    icon.classList.add('fa-bars');
  }
}

// Fetch and display chatRooms and groupChats from Firestore
window.addEventListener('firebaseReady', function() {
  try {
    const db = window.db;
    if (!db) {
      console.log("Firebase database not available");
      return;
    }

    const listItems = document.querySelector('.list-items');
    if (!listItems) {
      console.log("List items container not found");
      return;
    }

    // Clear existing hardcoded items
    listItems.innerHTML = '';

    // Fetch users from Firestore users collection
    db.collection('users').get().then(snapshot => {
      console.log('Users from Firestore:', snapshot.docs.length);

      snapshot.forEach(doc => {
        const userData = doc.data();
        const parentName = userData.parentName || 'Parent';
        const userName = userData.userName || 'User';
        const userId = doc.id;

        const item = document.createElement('div');
        item.className = 'list-item';
        item.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          loadChatFromFirestore(userId, false);
        });
        item.innerHTML = `
          <i class="fas fa-user-circle"></i>
          <div class="list-item-details">
            <div class="student-name">${parentName}</div>
            <div class="parent-name">${userName}</div>
          </div>
          <i class="fas fa-ellipsis-h"></i>
        `;
        listItems.appendChild(item);
      });
    }).catch(error => {
      console.log("Error fetching users from Firestore:", error);
    });

    // Fetch groupChats from Firestore
    db.collection('groupChats').get().then(snapshot => {
      snapshot.forEach(doc => {
        const data = doc.data();
        const groupName = data.groupName || 'Group Chat';
        const chatId = doc.id;

        const item = document.createElement('div');
        item.className = 'list-item';
        item.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          loadChatFromFirestore(chatId, true);
        });
        item.innerHTML = `
          <i class="fas fa-users"></i>
          <div class="list-item-details">
            <div class="student-name">Group</div>
            <div class="parent-name">${groupName}</div>
          </div>
          <i class="fas fa-ellipsis-h"></i>
        `;
        listItems.appendChild(item);
      });
    }).catch(error => {
      console.log("Error fetching groupChats:", error);
    });
  } catch (error) {
    console.log("Firebase ready error:", error);
  }
});

// When sending a message or fetching messages, always use sorted UIDs for chatRoomId
function getChatRoomId(adminId, userId) {
  return [adminId, userId].sort().join('_');
}
  </script>
</body>
</html>
