<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Settings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/settings.css') }}">
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principalsidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
</head>

<body>
    @if ($role === 'principal')
        @include('partials.principal-sidebar')
    @elseif($role === 'teacher')
        @include('partials.sidebar')
    @elseif($role === 'mswd')
        @include('sidebars.mswd')
    @else
        <p>No sidebar available for your role.</p>
    @endif
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
                        <div class="mb-3 position-relative">
                            <label for="current-password" class="form-label">Current Password</label>
                            <input type="password" class="form-control" id="current-password">
                            <span class="password-toggle" id="toggle-current-password">
                                <i class="fa fa-eye"></i>
                            </span>
                        </div>
                        <div class="mb-3 position-relative">
                            <label for="new-password" class="form-label">New Password</label>
                            <input type="password" class="form-control" id="new-password">
                            <span class="password-toggle" id="toggle-new-password">
                                <i class="fa fa-eye"></i>
                            </span>
                        </div>
                        <div class="mb-3 position-relative">
                            <label for="confirm-password" class="form-label">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirm-password">
                            <span class="password-toggle" id="toggle-confirm-password">
                                <i class="fa fa-eye"></i>
                            </span>
                        </div>
                        <button type="submit" class="btn btn-danger">Change Password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="reloginModal" tabindex="-1" aria-labelledby="reloginModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="reloginModalLabel">Authentication Required</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    Your email or password has been successfully updated. For security, please log in again with your new credentials.
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="relogin-btn">Log In Again</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', async () => {
            try {

                const auth = window.auth;
                const db = window.db;

                const reloginModal = new bootstrap.Modal(document.getElementById('reloginModal'));
                const reloginBtn = document.getElementById('relogin-btn');

                reloginBtn.addEventListener('click', async () => {
                    await auth.signOut();
                    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
                    await fetch('/logout-session', {
                        method: 'POST',
                        headers: {
                            'X-CSRF-TOKEN': csrfToken
                        }
                    });

                    window.location.href = '/login';
                });


                auth.onAuthStateChanged(async (user) => {
                    if (user) {
                        const adminDoc = await db.collection('admin').doc(user.uid).get();
                        if (adminDoc.exists) {
                            const adminData = adminDoc.data();
                            document.getElementById('name').value = adminData.name || adminData
                                .displayName || '';
                            document.getElementById('email').value = adminData.email || user
                                .email || '';
                        } else {
                            console.warn('No admin document found.');
                        }
                    } else {
                        console.warn('No user is signed in.');
                    }
                });

                // Password Change Logic
                const passwordForm = document.getElementById('password-form');
                passwordForm.addEventListener('submit', async (event) => {
                    event.preventDefault();

                    const user = auth.currentUser;
                    if (!user) {
                        alert('No user is currently signed in. Please log in and try again.');
                        return;
                    }

                    const currentPassword = document.getElementById('current-password').value;
                    const newPassword = document.getElementById('new-password').value;
                    const confirmPassword = document.getElementById('confirm-password').value;

                    if (newPassword !== confirmPassword) {
                        alert('New password and confirmation do not match.');
                        return;
                    }

                    if (newPassword.length < 6) {
                        alert('New password must be at least 6 characters long.');
                        return;
                    }

                    try {
                        const credential = firebase.auth.EmailAuthProvider.credential(user.email, currentPassword);
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPassword);

                        passwordForm.reset();
                        reloginModal.show();
                        
                    } catch (error) {
                        console.error('Error changing password:', error);
                        let errorMessage = 'An error occurred while changing the password. Please try again.';
                        
                        if (error.code === 'auth/wrong-password') {
                            errorMessage = 'The current password you entered is incorrect.';
                        } else if (error.code === 'auth/weak-password') {
                            errorMessage = 'The new password is too weak. Please choose a stronger one.';
                        } else if (error.code === 'auth/requires-recent-login') {
                            errorMessage = 'This action requires a recent login. Please log out and log in again before changing your password.';
                        }

                        alert(errorMessage);
                    }
                });

                // Email Change Logic
                const generalForm = document.getElementById('general-form');
                const editSaveBtn = document.getElementById('edit-save-btn');
                const nameInput = document.getElementById('name');
                const emailInput = document.getElementById('email');

                nameInput.disabled = true;
                emailInput.disabled = true;
                
                editSaveBtn.addEventListener('click', async () => {
                    if (editSaveBtn.innerText === 'Edit') {
                        editSaveBtn.innerText = 'Save';
                        editSaveBtn.classList.remove('btn-primary');
                        editSaveBtn.classList.add('btn-success');
                        nameInput.disabled = false;
                        emailInput.disabled = false;
                    } else {
                        const newEmail = emailInput.value;
                        const newName = nameInput.value;
                        const user = auth.currentUser;

                        if (!user) {
                            alert('No user is currently signed in.');
                            return;
                        }

                        const currentPassword = prompt('To save changes, please enter your current password:');
                        if (!currentPassword) {
                            alert('Email change canceled. You must provide your password.');
                            return;
                        }

                        try {
                            const credential = firebase.auth.EmailAuthProvider.credential(user.email, currentPassword);
                            await user.reauthenticateWithCredential(credential);

                            let updateRequired = false;

                            if (newName !== user.displayName) {
                                await user.updateProfile({
                                    displayName: newName
                                });
                                updateRequired = true;
                            }

                            if (newEmail !== user.email) {
                                await user.updateEmail(newEmail);
                                updateRequired = true;
                            }

                            await db.collection('admin').doc(user.uid).update({
                                displayName: newName,
                                name: newName,
                                email: newEmail,
                            });
                            
                            if (updateRequired) {
                                reloginModal.show();
                            } else {
                                alert('Settings updated successfully!');
                            }
                            
                        } catch (error) {
                            console.error('Error updating settings:', error);
                            let errorMessage = 'An error occurred while updating settings.';
                            if (error.code === 'auth/wrong-password') {
                                errorMessage = 'The password you entered is incorrect. Settings not updated.';
                            } else if (error.code === 'auth/email-already-in-use') {
                                errorMessage = 'The new email address is already in use by another account.';
                            } else if (error.code === 'auth/invalid-email') {
                                errorMessage = 'The new email address is invalid.';
                            }
                            alert(errorMessage);
                        }
                        
                        editSaveBtn.innerText = 'Edit';
                        editSaveBtn.classList.remove('btn-success');
                        editSaveBtn.classList.add('btn-primary');
                        nameInput.disabled = true;
                        emailInput.disabled = true;
                    }
                });
            } catch (error) {
                console.error('Error loading admin info:', error);
            }
        });

        document.addEventListener('DOMContentLoaded', function() {
            const toggleCurrentPassword = document.getElementById('toggle-current-password');
            const toggleNewPassword = document.getElementById('toggle-new-password');
            const toggleConfirmPassword = document.getElementById('toggle-confirm-password');
            const currentPasswordInput = document.getElementById('current-password');
            const newPasswordInput = document.getElementById('new-password');
            const confirmPasswordInput = document.getElementById('confirm-password');

            function toggleVisibility(icon, input) {
                icon.addEventListener('click', function() {
                    if (input.type === 'password') {
                        input.type = 'text';
                        icon.innerHTML = '<i class="fa fa-eye-slash"></i>';
                    } else {
                        input.type = 'password';
                        icon.innerHTML = '<i class="fa fa-eye"></i>';
                    }
                });
            }

            toggleVisibility(toggleCurrentPassword, currentPasswordInput);
            toggleVisibility(toggleNewPassword, newPasswordInput);
            toggleVisibility(toggleConfirmPassword, confirmPasswordInput);
        });
    </script>
</body>

</html>
