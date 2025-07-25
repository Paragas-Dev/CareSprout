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
    <link rel="stylesheet" href="{{ asset('css/people-stream.css') }}">

</head>
<body data-auth-user-name="{{ Auth::check() ? Auth::user()->name : 'Default Admin Name' }}">
    @include('partials.sidebar')
    <div class="main-container">
        <header>
            @include('partials.header')
        </header>
        <div class="hamburger-menu" onclick="toggleSidebar(this)">
          <i class="fas fa-bars"></i>
      </div>
        <div class="lessons-content">
            <div class="lesson-title-row">
              <h1><span id="lesson-title"></span></h1>
              <i class="fas fa-info-circle" title="About this lesson" style="color: #2f2f2f; cursor: pointer;"></i>
            </div>
            <div class="lessons-tabs">
                <span class="tab active" data-tab="stream">Stream</span>
                <span class="tab" data-tab="progress">Progress</span>
                <span class="tab" data-tab="people">People</span>
            </div>
            <div id="tab-content-stream">
                <div id="announcement-card" class="announcement-card">
                    <span>Announcement</span>
                    <i class="fas fa-plus"></i>
                </div>
                <div id="announcement-form-container" style="display:none;">
                    @include('partials.announcement-form')
                </div>
                <div id="posts-container"></div>
            </div>
            <div id="tab-content-progress" style="display:none;">
                <div style="padding: 40px; text-align: center; color: #aaa; font-size: 1.2em;">Progress under construction</div>
            </div>
            <div id="tab-content-people" style="display:none;">
                @include('lessons.people')
            </div>
        </div>
    </div>

    <!-- Centralized Firebase Configuration -->
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script src="https://cdn.ckeditor.com/4.25.1-lts/standard/ckeditor.js"></script>
    <script>

      function stripHtml(html) {
        var tmp = document.createElement("DIV");
        tmp.innerHTML = html;
        return tmp.textContent || tmp.innerText || "";
      }
      function getLessonIdFromUrl() {
        const parts = window.location.pathname.split('/');
        return parts[parts.length - 1];
      }
      const lessonId = getLessonIdFromUrl();
      let lessonName = '';

      // DOM Elements
      const announcementCard = document.getElementById('announcement-card');
      const announcementFormContainer = document.getElementById('announcement-form-container');
      const announcementForm = document.getElementById('new-announcement-form');
      const textarea = document.getElementById('announcement-text');
      const postBtn = document.getElementById('post-announcement');
      const cancelBtn = document.getElementById('cancel-announcement');
      const postsContainer = document.getElementById('posts-container');
      const lessonTitle = document.querySelector('h1 #lesson-title');

      const teacherListDiv = document.getElementById('teacher-list');
      const adminPerson = document.getElementById('admin-person-row');
      const adminName = adminPerson.querySelector('.person-name');

      const studentsPeopleList = document.getElementById('students-people-list');
      const studentsState = document.getElementById('students-empty-state');

      let currentUserName = 'Loading User...';

      // Firebase Ready Event
      window.addEventListener('firebaseReady', function() {
        const db = window.db;
        const auth = window.auth;

        auth.onAuthStateChanged(user => {
            if (user) {
                currentUserName = user.displayName || user.email || 'Admin';
                console.log('Firebase User Name:', currentUserName);
            } else {
                currentUserName = document.body.dataset.authUserName || 'Default Admin Name';
                console.log('No Firebase User. Using Laravel fallback (if available):', currentUserName);
            }
        })
        // Fetch Lesson Title
        db.collection('lessons').doc(lessonId).get().then(doc => {
          if (doc.exists) {
            lessonName = doc.data().name;
            lessonTitle.textContent = lessonName;
          } else {
            lessonTitle.textContent = 'Lesson Not Found';
          }
        });

        // Initial Post Rendering
        renderPostsFromFirestore();

        // Announcement Card Events
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

        // Announcement Form Submission
        announcementForm.onsubmit = function(e) {
            e.preventDefault();
            document.getElementById('announcement-text').value = document.getElementById('announcement-editor').innerHTML;
            const text = document.getElementById('announcement-text').value.trim();
            if (!text) return;

          // Remove HTML tags before saving
          const plainText = stripHtml(text);

          // Add new post to the start
          db.collection('lessons')
            .doc(lessonId)
            .collection('posts')
            .add({
              lessonId: lessonId,
              name: currentUserName,
              text: plainText,
              createdAt: firebase.firestore.FieldValue.serverTimestamp()
            })
            .then(() => {
              // Clear the text area
              const editor = document.getElementById('announcement-editor');
              if (editor) editor.innerHTML = '';
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

        // Render Posts
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
                  <div class="person-options">
                        <i class="fas fa-ellipsis-v"></i>
                    </div>
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
          })
          .catch(error => {
                console.error("Error getting posts: ", error);
                postsContainer.innerHTML = `<p style="color: red; text-align: center;">Error loading announcements.</p>`;
            });
        }

        function renderPeopleSection() {
            studentsPeopleList.innerHTML = '';
            studentsState.style.display = 'none';

            adminName.textContent = 'Loading Teacher...';

            db.collection('lessons').doc(lessonId)
                .get()
                .then(doc => {
                if (doc.exists) {
                    const lessonData = doc.data();
                    const creatorName = lessonData.createdBy && lessonData.createdBy.name
                                        ? lessonData.createdBy.name
                                        : 'Unknown Teacher';

                    adminName.textContent = creatorName;

                } else {
                    adminName.textContent = 'Lesson Not Found';
                }
            }).catch(error => {
                console.error("Error fetching lesson creator:", error);
                adminNameSpan.textContent = 'Error Loading Teacher';
            });

            db.collection('lessons')
                .doc(lessonId)
                .collection('joinedStudents')
                .get()
                .then(querySnapshot => {
                    if (querySnapshot.empty) {
                        studentsState.style.display = 'flex';
                        studentsPeopleList.appendChild(studentsState);
                    } else {
                        studentsState.style.display = 'none';
                        querySnapshot.forEach(doc => {
                            const student = doc.data();
                            const studentRow = document.createElement('div');
                            studentRow.className = 'person-row';
                            studentRow.innerHTML = `
                                <i class="fas fa-user-circle fa-2x"></i>
                                <span class="person-name">${student.name || 'Anonymous Student'}</span>
                                <div class="person-options">
                                    <i class="fas fa-ellipsis-v"></i>
                                </div>
                            `;
                            studentsPeopleList.appendChild(studentRow);
                        });
                    }
                }).catch(error => {
                    console.error("Error fetching joined students:", error);
                    studentsPeopleList.innerHTML = `<p style="color: red; text-align: center;">Error loading students.</p>`;
                    studentsState.style.display = 'none';
                })
        }

        // Tab Switching Logic
        document.querySelectorAll('.lessons-tabs .tab').forEach(tab => {
          tab.addEventListener('click', function() {
            document.querySelectorAll('.lessons-tabs .tab').forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            const selected = this.getAttribute('data-tab');

            document.getElementById('tab-content-stream').style.display = selected === 'stream' ? '' : 'none';
            document.getElementById('tab-content-progress').style.display = selected === 'progress' ? '' : 'none';
            document.getElementById('tab-content-people').style.display = selected === 'people' ? '' : 'none';

            if (selected === 'stream') {
                    document.getElementById('tab-content-stream').style.display = '';
                } else if (selected === 'progress') {
                    document.getElementById('tab-content-progress').style.display = '';
                } else if (selected === 'people') {
                    document.getElementById('tab-content-people').style.display = '';
                    renderPeopleSection();
                }
            });
        });

    }); // firebase EnD

      // Sidebar Toggle
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
