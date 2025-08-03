<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Principal Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/apps.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principalsidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
     <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>
<body>
    <div style="display: flex; height: 100vh;">
        @include('partials.principal-sidebar')
        <div class="main-content-wrapper">
            <header>
                @include('partials.header')
                <div class="hamburger-menu" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </div>
            </header>
            {{-- The actual dashboard content --}}
            <div class="dashboard-container">
                <div class="kpi-section">
                    <div class="kpi-card">
                        <p class="kpi-label">Total SPED Enrollment</p>
                        <p class="kpi-value" id="sped-enrollment-value">Loading...</p>
                    </div>
                    <div class="kpi-card">
                        <p class="kpi-label">E-learning Engagement</p>
                        <p class="kpi-value">92%</p>
                    </div>
                    <div class="kpi-card">
                        <p class="kpi-label">Community Engagement</p>
                        <p class="kpi-value">75%</p>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Academic Progress</h2>
                    <div class="chart-container">
                        <canvas id="academicChart"></canvas>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Announcement</h2>
                    <div class="announcement-box">
                        <h3>Recent Announcements</h3>
                        <div id="principal-announcements-container">
                            <p>Loading announcements...</p>
                        </div>
                        <a class="view-all" href="{{ route('announcements') }}">View All Announcements</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script src="{{ asset('js/bar_chart.js') }}"></script>
    <script>

    window.addEventListener('firebaseReady', function() {
        const db = window.db;

        function fetchSpedEnrollees() {
            const spedEnrollmentElement = document.getElementById('sped-enrollment-value');
            if (!spedEnrollmentElement) {
                console.error("SPED enrollment value element not found!");
                return;
            }
            spedEnrollmentElement.textContent = 'Loading...';

            db.collection('users')
                .where('status', '==', 'approved')
                .get()
                .then(snapshot => {
                    const totalApprovedSpedUsers = snapshot.size;
                    spedEnrollmentElement.textContent = totalApprovedSpedUsers;
                })
                .catch(error => {
                    console.error("Error fetching SPED enrollment:", error);
                    spedEnrollmentElement.textContent = 'Error';
                });
        }

        function fetchAnnouncements() {
            const container = document.getElementById('principal-announcements-container');
            if (!container) {
                console.error("Principal announcements container not found!");
                return;
            }
            container.innerHTML = '<p>Loading announcements...</p>';

            db.collection('announcements')
                .orderBy('createdAt', 'desc')
                .limit(3)
                .get()
                .then(snapshot => {
                    if (snapshot.empty) {
                        container.innerHTML = '<p>No announcements found.</p>';
                        return;
                    }
                    container.innerHTML = '';

                    snapshot.forEach(doc => {
                        const announcement = doc.data();
                        const announcementTitle = announcement.title || 'No Title';
                        const announcementContent = announcement.content || 'No Content';
                        const adminName = announcement.adminName || 'Unknown Administrator';

                        const date = announcement.createdAt ? new Date(announcement.createdAt.toDate()).toLocaleDateString('en-US', { month: '2-digit', day: '2-digit', year: 'numeric' }) : 'Unknown Date';

                        const announcementDiv = document.createElement('div');
                        announcementDiv.classList.add('announcement');

                        announcementDiv.innerHTML = `
                            <p class="announcement-title">${announcementTitle}</p>
                            <p class="announcement-content">${announcementContent}</p>
                            <p class="announcement-date-author">${date} | ${adminName}</p>
                        `;
                        container.appendChild(announcementDiv);
                    });
                })
                .catch(error => {
                    console.error("Error fetching principal announcements:", error);
                    container.innerHTML = '<p>Error loading announcements.</p>';
                });
        }

        fetchAnnouncements();
        fetchSpedEnrollees();
    });


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
    </script>
</body>
</html>
