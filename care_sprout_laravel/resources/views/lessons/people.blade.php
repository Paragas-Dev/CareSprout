<link rel="stylesheet" href="{{ asset('css/people-stream.css') }}">
<div class="people-tab-container">
  <div class="people-section">
    <div class="section-header">
      <h3>Teachers</h3>
      <div class="add-person-btn" id="add-teacher-btn">
          <i class="fas fa-user-plus"></i>
        </div>
    </div>
    <hr>
    <div class="teacher-list" id="teacher-list">
      <div class="person-row" id="admin-person-row">
        <i class="fas fa-user-circle fa-2x"></i>
        <span class="person-name">

        </span>
      </div>
    </div>
  </div>

  <div class="people-section">
    <div class="section-header">
      <h3>Students</h3>
      <div class="add-person-btn" id="add-student-btn">
          <i class="fas fa-user-plus"></i>
        </div>
    </div>
    <hr>
    <div class="people-list" id="students-people-list">

        <div class="empty-state" id="students-empty-state" style="display: none;">
            <div class="empty-illustration">
                <svg width="120" height="80" viewBox="0 0 120 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <ellipse cx="60" cy="70" rx="50" ry="8" fill="#f0f0f0"/>
                    <rect x="40" y="40" width="40" height="20" rx="4" fill="#e0e0e0"/>
                    <circle cx="60" cy="35" r="10" fill="#e0e0e0"/>
                    <path d="M65 45 Q60 50 55 45" stroke="#bdbdbd" stroke-width="2" fill="none"/>
                </svg>
            </div>
            <div class="empty-text">Add students to this class</div>
            <button class="invite-btn"><i class="fas fa-user-plus"></i> Invite students</button>
        </div>

    </div>
  </div>
</div>
