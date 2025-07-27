<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Principal Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/apps.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principal-sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
     <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>
<body>
     @include('partials.principal-sidebar')
     <div style="flex: 1; display: flex; flex-direction: column; min-height: 100vh;">
    <div style="width: 100%;">
        <header>
              @include('partials.header')
              <div class="hamburger-menu" onclick="toggleSidebar(this)">
         <i class="fas fa-bars"></i>
      </div>
        </header>
    <div class="dashboard-container">
        <!-- KPI Section -->
        <div class="kpi-section">
            <div class="kpi-card">
                <p class="kpi-label">Total SPED Enrollment</p>
                <p class="kpi-value">999</p>
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

        <!-- Academic Progress -->
        <div class="section">
            <h2 class="section-title">Academic Progress</h2>
            <div class="chart-container">
                <canvas id="academicChart"></canvas>
            </div>
        </div>

        <!-- Announcements -->
        <div class="section">
            <h2 class="section-title">Announcement</h2>
            <div class="announcement-box">
                <h3>Recent Announcements</h3>

                <div class="announcement">
                    <p class="announcement-title">Announcement Title</p>
                    <p class="announcement-date">Oct 14, 2024 · 4 min read</p>
                </div>
                <div class="announcement">
                    <p class="announcement-title">Announcement Title</p>
                    <p class="announcement-date">Oct 14, 2024 · 4 min read</p>
                </div>
                <div class="announcement">
                    <p class="announcement-title">Announcement Title</p>
                    <p class="announcement-date">Oct 14, 2024 · 4 min read</p>
                </div>

                <button class="view-all">View All Announcements</button>
            </div>
        </div>
    </div>

    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        const ctx = document.getElementById('academicChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['ASD', 'LD', 'ID', 'OHI', 'SLD'],
                datasets: [{
                    label: 'Scores',
                    data: [82, 75, 69, 85, 78],
                    backgroundColor: '#4b61e8',
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                },
                plugins: {
                    legend: {
                        position: 'top'
                    }
                }
            }
        });
    </script>
</body>
</html>
