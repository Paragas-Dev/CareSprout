<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Admin - CareSprout</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input, select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            padding: 12px;
            background-color: #1a73e8;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
        }
        button:hover {
            background-color: #1557b0;
        }
        button:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }
        .message {
            margin-top: 20px;
            padding: 10px;
            border-radius: 4px;
            text-align: center;
            font-weight: bold;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
    </style>
</head>
<body>
    <div class="container">
        <h1>Create Admin User</h1>
        
        <form id="createAdminForm">
            <div class="form-group">
                <label for="displayName">Display Name:</label>
                <input type="text" id="displayName" name="displayName" value="Admin Teacher" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" value="teacherAdmin@caresprout.com" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" value="243512" required>
            </div>
            
            <div class="form-group">
                <label for="role">Role:</label>
                <select id="role" name="role" required>
                    <option value="admin" selected>Principal</option>
                    <option value="teacher">Teacher</option>
                    <option value="mswd">MSWD Officer</option>
                </select>
            </div>
            
            <button type="submit" id="submitBtn">Create Admin User</button>
        </form>
        
        <div id="message"></div>
    </div>
    <script src="{{ asset('js/firebase-config.js') }}"></script>

    <script>
        // Wait for Firebase to be ready
        window.addEventListener('firebaseReady', function() {
            const auth = window.auth;
            const db = window.db;

        document.getElementById('createAdminForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const displayName = document.getElementById('displayName').value.trim();
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value.trim();
            const role = document.getElementById('role').value;
            const messageDiv = document.getElementById('message');
            const submitBtn = document.getElementById('submitBtn');
            
            if (!displayName || !email || !password || !role) {
                showMessage('Please fill in all fields', 'error');
                return;
            }
            
            // Disable submit button
            submitBtn.disabled = true;
            submitBtn.textContent = 'Creating...';
            
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
                            name: displayName,
                            displayName: displayName,
                            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
                        });
                    });
                })
                .then(() => {
                    showMessage(`✅ Admin user created and saved to Firestore! Email: ${email}`, 'success');
                    document.getElementById('createAdminForm').reset();
                })
                .catch((error) => {
                    showMessage(`❌ Error: ${error.message}`, 'error');
                })
                .finally(() => {
                    // Re-enable submit button
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Create Admin User';
                });
        });

        function showMessage(text, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.textContent = text;
            messageDiv.className = `message ${type}`;
        }
        });
    </script>
</body>
</html> 