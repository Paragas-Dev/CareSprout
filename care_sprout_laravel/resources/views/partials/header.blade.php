<div class="header-bar">
    <div class="header-logos">
      <img src="{{ asset('images/poz.png') }}" alt="Logo 1" class="header-logo" />
      <img src="{{ asset('images/1.png') }}" alt="Logo 2" class="header-logo" />
    </div>
<div class="user-info-bar">
  <div class="user-dropdown-container">
    <div class="user-info-card" onclick="toggleUserDropdown()">
        <i class="fas fa-bell" style="font-size: 22px; color: #AD781D; margin-right: 20px;"></i>
        <span class="user-info-avatar"><i class="fas fa-user"></i></span>
      <div class="user-info-details">
        <span class="user-info-name" id="user-info-name">Loading...</span>
        <span class="user-info-email" id="user-info-email">Loading...</span>
      </div>
      <i class="fas fa-angle-down user-info-arrow"></i>
    </div>
    <div id="user-dropdown" class="user-dropdown-content" style="display: none;" onclick="toggleUserDropdown()">
        <div class="dropdown-avatar">
            <i class="fas fa-user"></i>
        </div>
        <div class="dropdown-name" id="dropdown-name">Loading...</div>
        <div class="dropdown-email" id="dropdown-email">Loading...</div>
        <i class="fas fa-angle-up dropdown-arrow-up"></i>
    </div>
  </div>
</div>

<!-- Firebase is now initialized centrally via firebase-config.js -->

<script>
// Wait for Firebase to be ready
window.addEventListener('firebaseReady', function() {
  const auth = window.auth;
  const db = window.db;

  // Function to load user data from Firestore
  function loadUserData() {
    const currentUser = auth.currentUser;
    if (currentUser) {
      db.collection('admin').doc(currentUser.uid).get()
        .then((doc) => {
          if (doc.exists) {
            const userData = doc.data();
            const userName = userData.name || userData.displayName || 'Admin User';
            const userEmail = userData.email || currentUser.email || 'No email';
            document.getElementById('user-info-name').textContent = userName;
            document.getElementById('user-info-email').textContent = userEmail;
            document.getElementById('dropdown-name').textContent = userName;
            document.getElementById('dropdown-email').textContent = userEmail;
          } else {
            const userName = currentUser.displayName || 'Admin User';
            const userEmail = currentUser.email || 'No email';
            document.getElementById('user-info-name').textContent = userName;
            document.getElementById('user-info-email').textContent = userEmail;
            document.getElementById('dropdown-name').textContent = userName;
            document.getElementById('dropdown-email').textContent = userEmail;
          }
        })
        .catch((error) => {
          console.error("Error fetching user data:", error);
          const userName = currentUser.displayName || 'Admin User';
          const userEmail = currentUser.email || 'No email';
          document.getElementById('user-info-name').textContent = userName;
          document.getElementById('user-info-email').textContent = userEmail;
          document.getElementById('dropdown-name').textContent = userName;
          document.getElementById('dropdown-email').textContent = userEmail;
        });
    } else {
      document.getElementById('user-info-name').textContent = 'Not logged in';
      document.getElementById('user-info-email').textContent = 'Please log in';
      document.getElementById('dropdown-name').textContent = 'Not logged in';
      document.getElementById('dropdown-email').textContent = 'Please log in';
    }
  }

  auth.onAuthStateChanged(function(user) {
    if (user) {
      loadUserData();
    } else {
      window.location.href = '/login';
    }
  });
});

if (typeof toggleUserDropdown === 'undefined') {
  function toggleUserDropdown() {
    const dropdown = document.getElementById('user-dropdown');
    const arrow = document.querySelector('.user-info-arrow');
    if (dropdown.style.display === 'none' || dropdown.style.display === '') {
      dropdown.style.display = 'flex';
      arrow.classList.remove('fa-angle-down');
      arrow.classList.add('fa-angle-up');
    } else {
      dropdown.style.display = 'none';
      arrow.classList.remove('fa-angle-up');
      arrow.classList.add('fa-angle-down');
    }
  }
}
</script>
