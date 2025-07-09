<div class="sidebar mswd-sidebar">
    <div class="logo">
      <img src="{{ asset('images/name.png') }}" alt="CareSprout brand logo" />
    </div>
    <a class="menu-item {{ request()->is('mswd') ? 'active' : '' }}" href="/mswd">
      <i class="fas fa-tachometer-alt"></i> Dashboard
    </a>
    <a class="menu-item {{ request()->is('reports') ? 'active' : '' }}" href="/reports">
      <i class="fas fa-chart-bar"></i> Reports
    </a>
    <div class="bottom-menu">
      <div class="bottom-menu-item"><i class="fas fa-cog"></i> Settings</div>
      <div class="bottom-menu-item"><i class="fas fa-sign-out-alt"></i> Logout</div>
    </div>
</div> 