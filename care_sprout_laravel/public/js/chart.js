// Chart.js - Chart functionality for CareSprout

// Function to render gender distribution chart
function renderGenderChart(users) {
    console.log('renderGenderChart called with users:', users);

    if (users.length > 0) {
        console.log('Sample user data:', users[0]);
    }

    const maleCount = users.filter(u => u.gender && u.gender.toLowerCase() === 'male').length;
    const femaleCount = users.filter(u => u.gender && u.gender.toLowerCase() === 'female').length;

    console.log('Male count:', maleCount, 'Female count:', femaleCount);

    const ctx = document.getElementById('genderChart');
    if (!ctx) {
        console.error('Gender chart canvas not found');
        return;
    }

    // Destroy existing chart if it exists
    if (window.genderChart && typeof window.genderChart.destroy === 'function') {
        window.genderChart.destroy();
    }

    try {
        if (maleCount === 0 && femaleCount === 0) {
            // No gender data found, show total users
            const totalUsers = users.length;
            window.genderChart = new Chart(ctx.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: ['Total Users'],
                    datasets: [{
                        data: [totalUsers],
                        backgroundColor: ['#2d2d6e'],
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true,
                                font: {
                                    size: 12
                                }
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return `Total Users: ${context.parsed}`;
                                }
                            }
                        }
                    }
                }
            });
        } else {
            // Render gender-specific chart
            window.genderChart = new Chart(ctx.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: ['Male', 'Female'],
                    datasets: [{
                        data: [maleCount, femaleCount],
                        backgroundColor: ['#2d2d6e', '#AD781D'],
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true,
                                font: {
                                    size: 12
                                }
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.parsed;
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((value / total) * 100).toFixed(1);
                                    return `${label}: ${value} (${percentage}%)`;
                                }
                            }
                        }
                    }
                }
            });
        }
    } catch (error) {
        console.error('Error creating chart:', error);
    }
}

// Function to load and render gender chart from Firestore (admin-only)
function loadAndRenderGenderChart() {
    console.log('loadAndRenderGenderChart called');

    if (!window.db) {
        console.error('Firebase database not available');
        return;
    }

    const currentUser = firebase.auth().currentUser;

    if (!currentUser) {
        console.warn('User not authenticated');
        return;
    }

    const userId = currentUser.uid;

    // Check if the current user is an admin
    window.db.collection('admin').doc(userId).get()
        .then(adminDoc => {
            if (!adminDoc.exists) {
                console.warn('Not an admin – gender chart will not be shown.');
                return;
            }

            // Admin confirmed, fetch all users
            return window.db.collection('users').get();
        })
        .then(snapshot => {
            if (!snapshot) return;

            const users = snapshot.docs.map(doc => doc.data());
            renderGenderChart(users);
        })
        .catch(error => {
            console.error('Error loading users for chart:', error);
        });
}

// Initialize chart when Firebase is ready
document.addEventListener('DOMContentLoaded', function () {
    console.log('DOMContentLoaded - Chart.js loaded');

    if (window.db) {
        loadAndRenderGenderChart();
    } else {
        window.addEventListener('firebaseReady', function () {
            console.log('Firebase ready event fired, loading chart...');
            loadAndRenderGenderChart();
        });
    }
});
