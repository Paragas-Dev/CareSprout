<!-- Link to Principal Sidebar CSS -->
    <div class="sidebar">
        <div class="logo">
            <img src="{{ asset('images/name.png') }}" alt="CareSprout brand logo" />
        </div>

        <div class="menu-items">
            <a class="menu-item {{ request()->routeIs('principal.dashboard') ? 'active' : '' }}"
                href="{{ route('principal.dashboard') }}">
                <i class="fas fa-house"></i> Dashboard
            </a>
            <a class="menu-item {{ request()->routeIs('students') ? 'active' : '' }}" href="{{ route('students') }}">
                <i class="fas fa-user-graduate"></i> Students
            </a>
            <a class="menu-item {{ request()->routeIs('administrator') ? 'active' : '' }}"
                href="{{ route('administrator') }}">
                <i class="fas fa-user-shield"></i> Administrator
            </a>
            <a class="menu-item {{ request()->routeIs('approval') ? 'active' : '' }}" href="{{ route('approval') }}">
                <i class="fas fa-comments"></i> Messages
            </a>
            <a class="menu-item {{ request()->routeIs('announcements') ? 'active' : '' }}"
                href="{{ route('announcements') }}">
                <i class="fas fa-bullhorn"></i> Announcements
            </a>
        </div>

        <div class="bottom-menu-items">
            <a class="menu-item {{ request()->routeIs('settings') ? 'active' : '' }}" href="{{ route('settings') }}">
                <i class="fas fa-gear"></i> Settings
            </a>
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
