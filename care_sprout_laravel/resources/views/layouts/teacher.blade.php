php artisan serve
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
    </div>
    <div class="main-content">
      <div class="left-column fill-vertical">
        <div class="announcement-section fill-grow">
          <div id="announcement-trigger" onclick="toggleHomeAnnouncement(true)">
            <div class="announcement-placeholder">Announce something to your class</div>
          </div>
          <div id="home-announcement-form" class="home-announcement-form" style="display: none;">
            <textarea placeholder="Announce something to your class"></textarea>
            <div class="form-footer">
                <div class="form-actions">
                    <button class="cancel-btn" onclick="toggleHomeAnnouncement(false)">Cancel</button>
                    <button class="post-btn">Post</button>
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

        <div class="leaderboard-section fill-grow">
          <div class="leaderboard-header">
            <h2>LEADERBOARD</h2>
            <span class="leaderboard-view-all" onclick="window.location.href='{{ route('leader') }}'">View</span>
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
            </div>
          </div>
        </div>
      </div>

      <div class="right-column">
        <div class="student-list-section student-list-card">
          <div class="student-list-header">
            STUDENT LIST
          </div>
          <div class="student-list-search">
            <i class="fas fa-search"></i>
            <input type="text" placeholder="Search" />
          </div>
          <ul class="student-list-ul">
            <li>
              <span class="student-avatar"><i class="fas fa-user"></i></span>
              <span class="student-info">
                <span class="student-name">John Doe</span>
                <span class="parent-name">Mama Doe</span>
              </span>
              <span class="student-options"><i class="fas fa-ellipsis-h"></i></span>
            </li>

          </ul>
        </div>
        <div class="student-gender-section student-list-card">
          <div class="student-gender-chart-wrapper">
            <svg width="240" height="240" viewBox="0 0 240 240">
              <circle cx="120" cy="120" r="100" stroke="#e6e6e6" stroke-width="24" fill="none" />
              <circle cx="120" cy="120" r="100" stroke="#2d2d6e" stroke-width="24" fill="none" stroke-dasharray="120 628" stroke-linecap="round" transform="rotate(-90 120 120)" />
              <circle cx="120" cy="120" r="100" stroke="#AD781D" stroke-width="24" fill="none" stroke-dasharray="80 628" stroke-linecap="round" transform="rotate(-90 120 120)" />
              <text x="120" y="150" text-anchor="middle" font-size="38" fill="#AD781D" font-weight="bold">150</text>
              <text x="120" y="185" text-anchor="middle" font-size="22" fill="#888">Total</text>
            </svg>
          </div>
          <div class="student-gender-legend">
            <span><span class="legend-dot male"></span> Male</span>
            <span><span class="legend-dot female"></span> Female</span>
          </div>
        </div>
      </div>
    </div>
  </div>

  @include('partials.class-modal')
  <script src="{{ asset('js/firebase-config.js') }}"></script>
  
  <script>
      function goTo(url) {
        window.location.href = url;
      }

      function toggleHomeAnnouncement(showForm) {
        const trigger = document.getElementById('announcement-trigger');
        const form = document.getElementById('home-announcement-form');

        if (showForm) {
            trigger.style.display = 'none';
            form.style.display = 'block';
        } else {
            trigger.style.display = 'block';
            form.style.display = 'none';
        }
    }

    // Modal logic for Create Class
    const modal = document.getElementById('createClassModal');
    const addBtn = document.querySelector('.lessons-add-btn');
    const cancelBtn = document.getElementById('cancelCreateClass');
    const form = document.getElementById('createClassForm');
    const classNameInput = document.getElementById('classNameInput');
    const submitBtn = document.getElementById('submitCreateClass');
    const horizontalBoxList = document.querySelector('.horizontal-box-list');
    const colorCircles = document.querySelectorAll('.class-modal-color-circle');
    let selectedColor = '#dbeafe'; // default

    addBtn.addEventListener('click', () => {
      modal.style.display = 'flex';
      classNameInput.value = '';
      colorCircles.forEach((circle, idx) => {
        circle.classList.remove('selected');
        if(idx === 0) circle.classList.add('selected');
        if(circle.querySelector('.fa-check')) circle.querySelector('.fa-check').remove();
      });
      colorCircles[0].innerHTML = '<i class="fa fa-check"></i>';
      selectedColor = colorCircles[0].getAttribute('data-color');
      submitBtn.disabled = true;
      submitBtn.style.opacity = 0.7;
      classNameInput.focus();
    });
    colorCircles.forEach(circle => {
      circle.addEventListener('click', function() {
        colorCircles.forEach(c => { c.classList.remove('selected'); if(c.querySelector('.fa-check')) c.querySelector('.fa-check').remove(); });
        this.classList.add('selected');
        this.innerHTML = '<i class="fa fa-check"></i>';
        selectedColor = this.getAttribute('data-color');
      });
    });

    cancelBtn.addEventListener('click', () => {
      modal.style.display = 'none';
    });

    classNameInput.addEventListener('input', () => {
      if (classNameInput.value.trim() !== '') {
        submitBtn.disabled = false;
        submitBtn.style.opacity = 1;
      } else {
        submitBtn.disabled = true;
        submitBtn.style.opacity = 0.7;
      }
    });

    function renderLesson(className, color, lessonId) {
      const li = document.createElement('li');
      li.textContent = className;
      li.onclick = function() { goTo(`/lesson-stream/${lessonId}`); };
      li.style.background = color;
      horizontalBoxList.appendChild(li);
    }

    // Wait for Firebase to be ready before using it
    window.addEventListener('firebaseReady', function() {
      const db = window.db;
      
      function loadLessons() {
        horizontalBoxList.innerHTML = '';
        db.collection('lessons').orderBy('createdAt', 'asc').get().then(snapshot => {
          snapshot.forEach(doc => {
            const data = doc.data();
            renderLesson(data.name, data.color || '#dbeafe', doc.id);
          });
        });
      }

      loadLessons();

      form.addEventListener('submit', function(e) {
        e.preventDefault();
        const className = classNameInput.value.trim();
        if (className) {
          db.collection('lessons').add({
            name: className,
            color: selectedColor,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
          }).then(function(docRef) {
            loadLessons();
            modal.style.display = 'none';
          }).catch(function(error) {
            alert('Error saving lesson: ' + error.message);
          });
        }
      });
    });
  </script>
</body>
</html>
