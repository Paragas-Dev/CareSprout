@extends('layouts.principal')

@section('content')
<h2>Add New Admin (Teacher or MSWD Officer)</h2>
<form id="adminForm">
    <div>
        <label>Name:</label>
        <input type="text" id="displayName" name="displayName" required>
    </div>
    <div>
        <label>Email:</label>
        <input type="email" id="email" name="email" required>
    </div>
    <div>
        <label>Password:</label>
        <input type="password" id="password" name="password" required>
    </div>
    <div>
        <label>Role:</label>
        <select id="role" name="role" required>
            <option value="teacher">Teacher</option>
            <option value="mswd">MSWD Officer</option>
        </select>
    </div>
    <button type="submit">Create Admin</button>
</form>
<div id="message"></div>

<script src="{{ asset('js/firebase-config.js') }}"></script>

<script>
// Wait for Firebase to be ready
window.addEventListener('firebaseReady', function() {
    const auth = window.auth;
    const db = window.db;

document.getElementById('adminForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const displayName = document.getElementById('displayName').value.trim();
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value.trim();
    const role = document.getElementById('role').value;
    const messageDiv = document.getElementById('message');
    
    if (!displayName || !email || !password || !role) {
        messageDiv.textContent = 'Please fill in all fields';
        messageDiv.style.color = 'red';
        return;
    }
    
    // Create user in Firebase Auth
    auth.createUserWithEmailAndPassword(email, password)
        .then((userCredential) => {
            const user = userCredential.user;
            
            // Update user profile with display name
            return user.updateProfile({
                displayName: displayName
            }).then(() => {
                // Save user info to Firestore
                return db.collection('admin').doc(user.uid).set({
                    email: email,
                    role: role,
                    displayName: displayName,
                    createdAt: firebase.firestore.FieldValue.serverTimestamp()
                });
            });
        })
        .then(() => {
            messageDiv.textContent = 'Admin created successfully!';
            messageDiv.style.color = 'green';
            document.getElementById('adminForm').reset();
        })
        .catch((error) => {
            messageDiv.textContent = 'Error: ' + error.message;
            messageDiv.style.color = 'red';
        });
});
    });
</script>
@endsection
