<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>

  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/home.css') }}">
  <link rel="stylesheet" href="{{ asset('css/class-modal.css') }}">
</head>
<body>
  @include('partials.sidebar')
  <div style="flex: 1; display: flex; flex-direction: column; min-height: 100vh;">
    <div style="width: 100%;">
      @include('partials.header')
      <div class="hamburger-menu" onclick="toggleSidebar(this)">
         <i class="fas fa-bars"></i>
      </div>
    </div>
    <div class="main-content">
      <div class="left-column fill-vertical">
        <div class="announcement-section fill-grow">
          <div id="announcement-trigger" onclick="toggleHomeAnnouncement(true)">
            <div class="announcement-placeholder">Announce something to your class</div>
          </div>
          <div id="home-announcement-form" class="home-announcement-form" style="display: none;">
            <input type="text" id="announcement-title" placeholder="Announcement Title" style="width:100%;margin-bottom:10px;margin-right: 10px;padding:10px;font-size:16px;border-radius:6px;border:1px solid #ddd;">
            <textarea placeholder="Announce something to your class"></textarea>
            <div class="form-footer">
              <div class="form-actions">
                <button class="cancel-btn" onclick="toggleHomeAnnouncement(false)">Cancel</button>
                <button class="post-btn" type="button" onclick="postAnnouncement()">Post</button>
              </div>
            </div>
          </div>

          <div class="lessons-header-row">
            <h2 style="margin: 0;">LESSONS</h2>
            <button class="lessons-add-btn"><i class="fas fa-plus"></i></button>
          </div>
          <ul class="horizontal-box-list">
            <!-- Lessons will be loaded dynamically from Firestore -->
          </ul>
        </div>

        <div class="leaderboard-section">
          <div class="leaderboard-header">
            <h2>LEADERBOARD</h2>
          </div>
          <div class="leaderboard-podium">
            <div class="leaderboard-table">
              <div class="leaderboard-table-header">
                <div class="rank">#</div>
                <div class="name">Name</div>
                <div class="disability">Disability</div>
              </div>
              <div class="leaderboard-table-row">
                <div class="rank">1</div>
                <div class="avatar-wrapper"><span class="podium-avatar"><i class="fas fa-user"></i></span></div>
                <div class="name">Student Name</div>
                <div class="disability">Disability1</div>
              </div>
              <div class="leaderboard-table-row">
                <div class="rank">2</div>
                <div class="avatar-wrapper"><span class="podium-avatar"><i class="fas fa-user"></i></span></div>
                <div class="name">Student Name</div>
                <div class="disability">Disability3</div>
              </div>
              <div class="leaderboard-table-row">
                <div class="rank">3</div>
                <div class="avatar-wrapper"><span class="podium-avatar"><i class="fas fa-user"></i></span></div>
                <div class="name">Student Name</div>
                <div class="disability">Disability2</div>
              </div>
              <div class="leaderboard-table-row">
                <div class="rank">4</div>
                <div class="avatar-wrapper"><span class="podium-avatar"><i class="fas fa-user"></i></span></div>
                <div class="name">Student Name</div>
                <div class="disability">Disability2</div>
              </div>
              <div class="leaderboard-table-row">
                <div class="rank">5</div>
                <div class="avatar-wrapper"><span class="podium-avatar"><i class="fas fa-user"></i></span></div>
                <div class="name">Student Name</div>
                <div class="disability">Disability2</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="right-column">
        <div class="student-list-section student-list-card">
          <div class="student-list-header">STUDENT LIST</div>
          <div class="student-list-search">
            <i class="fas fa-search"></i>
            <input type="text" id="studentSearchInput" placeholder="Search" />
          </div>
          <ul class="student-list-ul">
            <!-- Students will be loaded here -->
          </ul>
        </div>
        <div class="student-gender-section student-list-card">
          <div class="student-gender-chart-wrapper">
            <canvas id="genderChart" width="400" height="400"></canvas>
          </div>
        </div>
      </div>
    </div>
  </div>

  @include('partials.class-modal')

  <!-- Success Modal for Announcement Posted -->
  <div id="successModal" class="class-modal" style="display: none;">
    <div class="class-modal-content">
      <h2 class="class-modal-title">Success!</h2>
      <div style="text-align: center; padding: 20px;">
        <i class="fas fa-check-circle" style="font-size: 48px; color: #10b981; margin-bottom: 15px;"></i>
        <p id="successMessage" style="font-size: 16px; color: #374151; margin: 0;">Announcement Posted!</p>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="{{ asset('js/chart.js') }}"></script>
  <script src="{{ asset('js/firebase-config.js') }}"></script>

  <script>
    function goTo(url) {
      window.location.href = url;
    }

    // Success Modal Functions
    function showSuccessModal(message) {
        const modal = document.getElementById('successModal');
        const messageElement = document.getElementById('successMessage');
        if (messageElement) {
            messageElement.textContent = message;
        }
        modal.style.display = 'flex';

        setTimeout(() => {
            closeSuccessModal();
        }, 2500);
    }

    function closeSuccessModal() {
        const modal = document.getElementById('successModal');
        modal.style.display = 'none';
    }

    document.getElementById('successModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeSuccessModal();
        }
    });

    // Sidebar Toggle
    function toggleSidebar(element) {
      const sidebar = document.querySelector('.sidebar');
      sidebar.classList.toggle('open');
      const icon = element.querySelector('i');
      if (sidebar.classList.contains('open')) {
        icon.classList.remove('fa-bars');
        icon.classList.add('fa-times');
      } else {
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
      }
    }

    // Announcement Form Toggle
    window.toggleHomeAnnouncement = function(showForm) {
      const trigger = document.getElementById('announcement-trigger');
      const form = document.getElementById('home-announcement-form');
      const lessonList = document.querySelector('.horizontal-box-list');
      if (showForm) {
        trigger.style.display = 'none';
        form.style.display = 'block';
        if (lessonList) lessonList.classList.add('shrink');
      } else {
        trigger.style.display = 'block';
        form.style.display = 'none';
        if (lessonList) lessonList.classList.remove('shrink');
      }
    }

    // submission of announcement
    window.postAnnouncement = function () {
        const textarea = document.querySelector('#home-announcement-form textarea');
        const content = textarea.value.trim();
        const titleInput = document.getElementById('announcement-title');
        const title = titleInput ? titleInput.value.trim() : '';
        if (!content || !title) return;

        firebase.auth().onAuthStateChanged(function (currentUser) {
            if (!currentUser) {
                alert('No authenticated user found');
                return;
            }

            const adminUid = currentUser.uid;

            window.db.collection('admin').doc(adminUid)
                .get()
                .then(adminDoc => {
                    if (!adminDoc.exists) {
                        alert('You do not have administrative privileges to post announcements.');
                        return;
                    }

                    const adminData = adminDoc.data();
                    const adminName = adminData.displayName || adminData.name || 'Admin';

                    return window.db.collection('announcements').add({
                        title: title,
                        content: content,
                        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                        adminId: adminUid,
                        adminName: adminName,
                    });
                })
                .then(() => {
                    textarea.value = '';
                    if (titleInput) titleInput.value = '';
                    toggleHomeAnnouncement(false);
                    showSuccessModal('Announcement Posted!');
                })
                .catch(error => {
                    alert(error.message);
                });
        });
    }
    // Lesson Creation Logic
    const modal = document.getElementById('createClassModal');
    const addBtn = document.querySelector('.lessons-add-btn');
    const cancelBtn = document.getElementById('cancelCreateClass');
    const form = document.getElementById('createClassForm');
    const classNameInput = document.getElementById('classNameInput');
    const submitBtn = document.getElementById('submitCreateClass');
    const horizontalBoxList = document.querySelector('.horizontal-box-list');
    const colorCircles = document.querySelectorAll('.class-modal-color-circle');
    let selectedColor = '#dbeafe';

    // Open modal for creating a lesson
    addBtn.addEventListener('click', () => {
      modal.style.display = 'flex';
      classNameInput.value = '';
      colorCircles.forEach((circle, idx) => {
        circle.classList.remove('selected');
        if (idx === 0) circle.classList.add('selected');
        if (circle.querySelector('.fa-check')) circle.querySelector('.fa-check').remove();
      });
      colorCircles[0].innerHTML = '<i class="fa fa-check"></i>';
      selectedColor = colorCircles[0].getAttribute('data-color');
      submitBtn.disabled = true;
      submitBtn.style.opacity = 0.7;
      classNameInput.focus();
    });

    // Color selection for lesson
    colorCircles.forEach(circle => {
      circle.addEventListener('click', function () {
        colorCircles.forEach(c => {
          c.classList.remove('selected');
          if (c.querySelector('.fa-check')) c.querySelector('.fa-check').remove();
        });
        this.classList.add('selected');
        this.innerHTML = '<i class="fa fa-check"></i>';
        selectedColor = this.getAttribute('data-color');
      });
    });

    // Cancel creation of lesson
    cancelBtn.addEventListener('click', () => {
      modal.style.display = 'none';
    });

    // Enable/disable submit button based on input
    classNameInput.addEventListener('input', () => {
      if (classNameInput.value.trim() !== '') {
        submitBtn.disabled = false;
        submitBtn.style.opacity = 1;
      } else {
        submitBtn.disabled = true;
        submitBtn.style.opacity = 0.7;
      }
    });
    // Lesson Rendering
    function renderLesson(className, color, lessonId) {
      const li = document.createElement('li');
      li.textContent = className;
      li.onclick = function () { goTo(`/lesson-stream/${lessonId}`); };
      li.style.background = color;
      horizontalBoxList.appendChild(li);
    }

    // Generates 6-character alphanumeric code
    function generateLessonCode(length = 6) {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      let code = '';
      for (let i = 0; i < length; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return code;
    }

    // Firestore Integration for Lessons
    window.addEventListener('firebaseReady', function () {
      const db = window.db;

      // Load all lessons from Firestore
      function loadLessons() {
        horizontalBoxList.innerHTML = '';
        db.collection('lessons').orderBy('createdAt', 'asc')
            .where("status", "==", "active")
            .limit(4)
            .get()
            .then(snapshot => {
                snapshot.forEach(doc => {
                const data = doc.data();
                renderLesson(data.name, data.color || '#dbeafe', doc.id);
             });

             if (snapshot.size === 4) {
                const viewAllLi = document.createElement('li');
                viewAllLi.className = 'view=all-lessons';
                viewAllLi.innerHTML = 'View All &rarr;';
                viewAllLi.onclick = function () {
                    goTo('{{ route('lessons.home') }}');
                };
                horizontalBoxList.appendChild(viewAllLi);
             }
        }).catch(error => {
            console.error("Error loading lessons for home:", error);
            horizontalBoxList.innerHTML = '<li style="color:#888;">Error loading lessons.</li>';
        });
      }

      loadLessons();
      loadApprovedStudents();

      // Handle lesson creation form submission
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        const className = classNameInput.value.trim();

        const creatorId = currentUser.uid;
        const creatorName = currentUser.displayName || currentUser.email || 'Unknown Creator';
        if (className) {
          db.collection('lessons').add({
            name: className,
            color: selectedColor,
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            joinCode: generateLessonCode().toUpperCase(),
            status: 'active',
            createdBy: {
                name: creatorName
            }
          }).then(function (docRef) {
            db.collection('lessons').doc(docRef.id).get().then(doc => {
              if (doc.exists) {
                const joinCode = doc.data().joinCode;
                alert('Lesson created! Share this code: ' + joinCode);
              }
              loadLessons();
              modal.style.display = 'none';
            });
          }).catch(function (error) {
            alert('Error saving lesson: ' + error.message);
          });
        }
      });
    });

    //load approved students
    let approvedStudents = [];

    function loadApprovedStudents() {
        const studentList = document.querySelector('.student-list-ul');
        if (!studentList) return;

        studentList.innerHTML = '';

        const currentUser = firebase.auth().currentUser;

        if (!currentUser) {
            console.error('Not signed in');
            return;
        }

        const userId = currentUser.uid;

        window.db.collection('admin').doc(userId).get()
            .then(doc => {
                if (!doc.exists) {
                    console.warn('Not an admin. Skipping loading approved students.');
                    studentList.innerHTML = '<li style="color:#888;">Only admin can view student list.</li>';
                    return;
                }

                //fetch the approved students from firestore
            return window.db.collection('users')
                .where('status', '==', 'approved')
                .limit(10)
                .get()
                .then(snapshot => {
                    if (snapshot.empty) {
                        studentList.innerHTML = '<li style="color:#888;">No approved students found.</li>';
                        approvedStudents = [];
                        return;
                    }

                    approvedStudents = [];
                    snapshot.forEach(doc => {
                        const user = doc.data();
                        user.id = doc.id;
                        approvedStudents.push(user);

                        const li = document.createElement('li');
                        li.textContent = user.userName || user.email || 'Unknown Student';
                        li.setAttribute('data-user-id', doc.id);
                        studentList.appendChild(li);
                    });
                });
            })
            .catch(error => {
                console.error('Error loading students:', error);
                studentList.innerHTML = '<li style="color:#888;">Error loading students.</li>';
            });
    }

    // Search functionality for students
    document.getElementById('studentSearchInput').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase().trim();
        const studentList = document.querySelector('.student-list-ul');

        if (!studentList) return;

        studentList.innerHTML = '';

        if (searchTerm === '') {
            // If search is empty, show all approved students
            approvedStudents.forEach(user => {
                const li = document.createElement('li');
                li.textContent = user.userName || user.email || 'Unknown Student';
                li.setAttribute('data-user-id', user.id);
                studentList.appendChild(li);
            });
        } else {
            // Filter students based on search term
            const filteredStudents = approvedStudents.filter(user => {
                const userName = (user.userName || '').toLowerCase();
                const email = (user.email || '').toLowerCase();
                const parentName = (user.parentName || '').toLowerCase();
                const lrn = (user.LRN || '').toLowerCase();

                return userName.includes(searchTerm) ||
                       email.includes(searchTerm) ||
                       parentName.includes(searchTerm) ||
                       lrn.includes(searchTerm);
            });

            if (filteredStudents.length === 0) {
                studentList.innerHTML = '<li style="color:#888;">No students found matching "' + searchTerm + '"</li>';
            } else {
                filteredStudents.forEach(user => {
                    const li = document.createElement('li');
                    li.textContent = user.userName || user.email || 'Unknown Student';
                    li.setAttribute('data-user-id', user.id);
                    studentList.appendChild(li);
                });
            }
        }
    });
  </script>
</body>
</html>
