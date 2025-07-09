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
            Messages
            <i class="fas fa-ellipsis-h"></i>
          </div>
          <div class="chat-fade-top"></div>
          <div class="chat-messages">
            <div class="chat-message parent-message">
              <p><strong>Parent:</strong> Hello!</p>
            </div>
            <div class="chat-message user-message">
              <p><strong>You:</strong> Hi! How can I help?</p>
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
          <div class="list-header">LIST</div>
          <div class="list-search">
            <i class="fas fa-search"></i>
            <input type="text" placeholder="Search" />
          </div>
          <div class="list-items">
            <div class="list-item" onclick="loadChat('Parent Name 1')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Student Name</div>
                <div class="parent-name">Parent Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
            <div class="list-item" onclick="loadChat('Parent Name 2')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Student Name</div>
                <div class="parent-name">Parent Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
            <div class="list-item" onclick="loadChat('Parent Name 3')">
              <i class="fas fa-user-circle"></i>
              <div class="list-item-details">
                <div class="student-name">Student Name</div>
                <div class="parent-name">Parent Name</div>
              </div>
              <i class="fas fa-ellipsis-h"></i>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    function toggleDropdown(element) {
      element.classList.toggle("active");
    }

    document.addEventListener("click", function(event) {
      const drop = document.querySelector(".drop");
      if (!drop.contains(event.target)) {
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

    function sendReply() {
      const input = document.getElementById('replyInput');
      const message = input.value.trim();

      if (message !== "") {
        const chatMessages = document.querySelector('.chat-messages');
        const reply = document.createElement('div');
        reply.classList.add('chat-message', 'user-message');
        reply.innerHTML = `<p><strong>You:</strong> ${message}</p>`;
        chatMessages.appendChild(reply);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        input.value = '';
      }
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
  </script>
</body>
</html>
