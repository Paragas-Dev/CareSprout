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
        <a class="menu-item {{ request()->routeIs('lessons.home') ? 'active' : '' }}"
            href="{{ route('lessons.home') }}">
            <i class="fas fa-book"></i> Lessons
        </a>
        <a class="menu-item {{ request()->routeIs('studentList') ? 'active' : '' }}" href="{{ route('studentList') }}">
            <i class="fas fa-chart-bar"></i> Student List
        </a>
        <a class="menu-item {{ request()->routeIs('reports') ? 'active' : '' }}" href="{{ route('reports') }}">
            <i class="fas fa-chart-bar"></i> Reports
        </a>
        <a class="menu-item {{ request()->routeIs('approval') ? 'active' : '' }}" href="{{ route('approval') }}">
            <i class="fas fa-check-circle"></i> Approval
        </a>
        <a class="menu-item {{ request()->routeIs('leader') ? 'active' : '' }}" href="{{ route('leader') }}">
            <i class="fas fa-trophy"></i> Leaderboard
        </a>
        <a class="menu-item {{ request()->routeIs('announcement') ? 'active' : '' }}"
            href="{{ route('announcement') }}">
            <i class="fas fa-bullhorn"></i> Announcements
        </a>
    </div>

    <div class="bottom-menu-items">
        <a class="menu-item {{ request()->routeIs('settings') ? 'active' : '' }}" href="{{ route('settings') }}"><i
                class="fas fa-cog"></i> Settings</a>
        <a class="menu-item {{ request()->routeIs('lessons.archived') ? 'active' : '' }}"
            href="{{ route('lessons.archived') }}"><i class="fas fa-archive"></i> Archived Lessons</a>
        <a class="menu-item" href="#" id="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const logoutBtn = document.getElementById('logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', function(e) {
                e.preventDefault();
                if (window.auth && window.auth.signOut) {
                    window.auth.signOut().then(async function() {
                        await fetch('/logout-session', {
                            method: 'POST',
                            headers: {
                                'X-CSRF-TOKEN': '{{ csrf_token() }}'
                            }
                        });
                        window.location.href = '/login';
                    }).catch(function(error) {
                        alert('Logout failed;' + error.message);
                    });
                } else {
                    alert('Firebase not initialized.')
                }
            })
        }
    })
</script>
<script src="/js/sidebar-lessons.js"></script>
