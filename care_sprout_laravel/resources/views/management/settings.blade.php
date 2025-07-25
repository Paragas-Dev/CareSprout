<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Settings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/settings.css') }}">
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
</head>
<body>
    @include('partials.sidebar')
    <div class="main-container">
        <header>
            @include('partials.header')
        </header>
        <div class="settings-container">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">General Settings</h5>
                    <form id="general-form">
                        <div class="mb-3">
                            <label for="name" class="form-label">Your name</label>
                            <input type="text" class="form-control" id="name" value=" ">
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label">Your Email</label>
                            <input type="email" class="form-control" id="email" value=" ">
                        </div>
                        <button type="button" class="btn btn-primary" id="edit-save-btn">Edit</button>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Change Password</h5>
                    <p class="card-text">Update your account password for enhanced security.</p>
                    <form id="password-form">
                        <div class="mb-3">
                            <label for="current-password" class="form-label">Current Password</label>
                            <input type="password" class="form-control" id="current-password">
                        </div>
                        <div class="mb-3">
                            <label for="new-password" class="form-label">New Password</label>
                            <input type="password" class="form-control" id="new-password">
                        </div>
                        <div class="mb-3">
                            <label for="confirm-password" class="form-label">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirm-password">
                        </div>
                        <button type="submit" class="btn btn-danger">Change Password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', async () => {
            try {
                auth.onAuthStateChanged(async (user) => {
                    if (user) {
                        const adminDoc = await db.collection('admin').doc(user.uid).get();
                        if (adminDoc.exists) {
                            const adminData = adminDoc.data();
                            document.getElementById('name').value = adminData.name || adminData.displayName || '';
                            document.getElementById('email').value = adminData.email || user.email || '';
                        } else {
                            console.warn('No admin document found.');
                        }
                    } else {
                        console.warn('No user is signed in.');
                    }
                });
            } catch (error) {
                console.error('Error loading admin info:', error);
            }
        });
    </script>
</body>
</html>
