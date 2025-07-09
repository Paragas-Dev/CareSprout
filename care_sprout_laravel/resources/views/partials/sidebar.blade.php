<div class="sidebar">
  <div class="logo">
    <img src="{{ asset('images/name.png') }}" alt="CareSprout brand logo" />
  </div>

  <div class="menu-items">
    <a class="menu-item {{ request()->routeIs('home') ? 'active' : '' }}" href="{{ route('home') }}">
      <i class="fas fa-tachometer-alt"></i> Dashboard
    </a>
    <a class="menu-item {{ request()->routeIs('messages') ? 'active' : '' }}" href="{{ route('messages') }}">
      <i class="fas fa-envelope"></i> Messages
    </a>
    <div class="menu-item has-dropdown" id="lessons-toggle" onclick="toggleSubmenu(this)">
      <i class="fas fa-book"></i> Lessons <i class="fas fa-chevron-down dropdown-icon"></i>
    </div>
    <div class="submenu" id="lessons-submenu">
      <!-- Lesson links will be populated dynamically -->
    </div>
    <a class="menu-item {{ request()->routeIs('approval') ? 'active' : '' }}" href="{{ route('approval') }}">
      <i class="fas fa-check-circle"></i> Approval
    </a>
  </div>

  <div class="bottom-menu-items">
    <a class="menu-item" href="#"><i class="fas fa-cog"></i> Settings</a>
    <a class="menu-item {{ request()->routeIs('reports') ? 'active' : '' }}" href="{{ route('reports') }}">
      <i class="fas fa-chart-bar"></i> Reports
    </a>
    <a class="menu-item" href="#"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </div>
</div>

<script>
  function toggleSubmenu(element) {
    const submenu = document.getElementById('lessons-submenu');
    const icon = element.querySelector('.dropdown-icon');
    const STORAGE_KEY = 'sidebar-lessons-open';
    if (submenu.style.display === 'block') {
      submenu.style.display = 'none';
      icon.classList.remove('fa-chevron-up');
      icon.classList.add('fa-chevron-down');
      localStorage.setItem(STORAGE_KEY, 'false');
    } else {
      submenu.style.display = 'block';
      icon.classList.remove('fa-chevron-down');
      icon.classList.add('fa-chevron-up');
      localStorage.setItem(STORAGE_KEY, 'true');
    }
  }
  // Restore submenu state on page load
  document.addEventListener('DOMContentLoaded', function() {
    const submenu = document.getElementById('lessons-submenu');
    const icon = document.querySelector('#lessons-toggle .dropdown-icon');
    const STORAGE_KEY = 'sidebar-lessons-open';
    if (localStorage.getItem(STORAGE_KEY) === 'true') {
      submenu.style.display = 'block';
      if (icon) {
        icon.classList.remove('fa-chevron-down');
        icon.classList.add('fa-chevron-up');
      }
    } else {
      submenu.style.display = 'none';
      if (icon) {
        icon.classList.remove('fa-chevron-up');
        icon.classList.add('fa-chevron-down');
      }
    }
  });
</script>
<script src="/js/sidebar-lessons.js"></script> 