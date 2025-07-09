<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Letters</title>
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/lesson-stream.css') }}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/announcement-form.css') }}">

</head>
<body>
    @include('partials.sidebar')
    <div class="main-container">
        @include('partials.header')
        <div class="hamburger-menu" onclick="toggleSidebar(this)">
          <i class="fas fa-bars"></i>
      </div>
        <div class="letters-content">
            <h1></h1>
            <div class="letters-tabs">
                <span class="tab active">Stream</span>
                <span class="tab">Progress</span>
                <span class="tab">People</span>
            </div>
            <div id="announcement-card" class="announcement-card">
                <span>Announcement</span>
                <i class="fas fa-plus"></i>
            </div>
            <div id="announcement-form-container" style="display:none;">
                @include('partials.announcement-form')
            </div>
            <div id="posts-container"></div>
        </div>
    </div>
    
    <!-- Centralized Firebase Configuration -->
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
    <script>
      function getLessonIdFromUrl() {
        const parts = window.location.pathname.split('/');
        return parts[parts.length - 1];
      }
      const lessonId = getLessonIdFromUrl();
      let lessonName = '';

      // Elements
      const announcementCard = document.getElementById('announcement-card');
      const announcementFormContainer = document.getElementById('announcement-form-container');
      const announcementForm = document.getElementById('new-announcement-form');
      const textarea = document.getElementById('announcement-text');
      const postBtn = document.getElementById('post-announcement');
      const cancelBtn = document.getElementById('cancel-announcement');
      const postsContainer = document.getElementById('posts-container');
      const lessonTitle = document.querySelector('h1');

      window.addEventListener('firebaseReady', function() {
        const db = window.db;
        
        db.collection('lessons').doc(lessonId).get().then(doc => {
          if (doc.exists) {
            lessonName = doc.data().name;
            lessonTitle.textContent = lessonName;
          } else {
            lessonTitle.textContent = 'Lesson Not Found';
          }
        });

      announcementCard.addEventListener('click', function() {
        announcementCard.style.display = 'none';
        announcementFormContainer.style.display = 'block';
        setTimeout(function() {
          if (CKEDITOR.instances['announcement-text']) {
            CKEDITOR.instances['announcement-text'].focus();
          }
        }, 100);
      });

      cancelBtn.onclick = function() {
        announcementFormContainer.style.display = 'none';
        announcementCard.style.display = 'flex';
      };

      textarea.addEventListener('input', function() {
        if (textarea.value.trim()) {
          postBtn.disabled = false;
          postBtn.style.opacity = 1;
          postBtn.style.cursor = 'pointer';
          postBtn.style.background = '#1a73e8';
          postBtn.style.color = '#fff';
        } else {
          postBtn.disabled = true;
          postBtn.style.opacity = 1;
          postBtn.style.cursor = 'not-allowed';
          postBtn.style.background = '#e3e3e3';
          postBtn.style.color = '#b0b0b0';
        }
      });

      announcementForm.onsubmit = function(e) {
        e.preventDefault();
        const text = textarea.value.trim();
        if (!text) return;

        // Add new post to the start
        db.collection('lessons')
        .doc(lessonId)
        .collection('posts')
        .add({
          lessonId: lessonId,
          name: 'Admin Name',
          text: text,
          createdAt: firebase.firestore.FieldValue.serverTimestamp()
        })
        .then(() => {
          // Clear the text area
        textarea.value = '';
        postBtn.disabled = true;
        postBtn.style.opacity = 1;
        postBtn.style.cursor = 'not-allowed';
        postBtn.style.background = '#e3e3e3';
        postBtn.style.color = '#b0b0b0';

        // Hide form, show card, and re-render posts
        announcementFormContainer.style.display = 'none';
        announcementCard.style.display = 'flex';
        renderPostsFromFirestore();
        });
      };

      // Render posts
      function renderPostsFromFirestore() {
        db.collection('lessons')
        .doc(lessonId)
        .collection('posts')
        .orderBy('createdAt', 'desc')
        .get()
        .then(querySnapshot => {
          postsContainer.innerHTML = '';
          querySnapshot.forEach(doc => {
            const post = doc.data();
            const postDiv = document.createElement('div');
            postDiv.className = 'post-card dynamic-post';
            postDiv.innerHTML = `
              <div class="post-header">
                <i class="fas fa-user-circle"></i>
                <span>${post.name}</span>
              </div>
              <div class="post-body">
                <p>${post.text}</p>
              </div>
              <div class="post-footer">
                <input type="text" placeholder="Add comment">
                <i class="fas fa-paper-plane"></i>
              </div>
            `;
            postsContainer.appendChild(postDiv);
          });
          postsContainer.scrollTop = postsContainer.scrollHeight;
        });
      }

      });
    
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