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
