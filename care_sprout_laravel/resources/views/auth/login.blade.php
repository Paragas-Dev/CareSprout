<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <title>CareSprout Login</title>
    <link rel="stylesheet" href="{{ asset('css/login.css') }}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
        integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />
    <script src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.mjs" type="module"></script>
</head>

<body>

    <div class="container">
        <div class="title">
            <img src="{{ asset('images/name.png') }}" alt="CareSprout Logo" style="max-width: 100%; height: auto;" />
        </div>
        <div class="subtitle">Log In</div>

        <form id="loginForm">
            <div class="message" id="message"></div>

            <input type="email" id="email" placeholder="Email" required /><br />
            <div id="password-container" class="password-container">
                <input type="password" id="password" placeholder="Password" required />
                <span id="togglePassword" class="toggle-password">
                    <i class="fas fa-eye"></i>
                </span>
            </div>
            <br />
            <div class="links"><a href="#">Forgot password</a></div>
            <input type="submit" value="Log in" />
        </form>
    </div>

    <div id="success-modal" class="modal-overlay" style="display: none;">
        <div class="modal-content">
            <dotlottie-player src="https://lottie.host/d1b1fc5d-998e-4d2b-b20e-c46dfbbe02f9/ndMCJOaqH5.lottie"
                background="transparent" speed="1" style="width: 300px; height: 300px" autoplay>
            </dotlottie-player>
            <p>Login successful!</p>
        </div>
    </div>

    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', function() {
            const auth = window.auth;
            const db = window.db;

            const loginForm = document.getElementById('loginForm');
            const message = document.getElementById('message');

            const togglePassword = document.getElementById('togglePassword');
            const passwordInput = document.getElementById('password');

            togglePassword.addEventListener('click', function() {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);

                this.querySelector('i').classList.toggle('fa-eye');
                this.querySelector('i').classList.toggle('fa-eye-slash');
            });

            loginForm.addEventListener('submit', async function(e) {
                e.preventDefault();

                const emailInput = document.getElementById('email');
                const passwordInput = document.getElementById('password');
                const email = emailInput.value.trim();
                const password = passwordInput.value.trim();

                // Reset
                message.textContent = '';
                emailInput.style.border = '2px solid transparent';
                passwordInput.style.border = '2px solid transparent';

                try {
                    const userCredential = await auth.signInWithEmailAndPassword(email, password);
                    const user = userCredential.user;

                    const adminDoc = await db.collection('admin').doc(user.uid).get();
                    if (!adminDoc.exists) {
                        throw {
                            code: 'not-admin'
                        };
                    }

                    const role = adminDoc.data().role;
                    sessionStorage.setItem('userRole', role);

                    await fetch('/set-role', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': '{{ csrf_token() }}'
                        },
                        body: JSON.stringify({
                            role
                        })
                    });

                    // Show success modal
                    const modal = document.getElementById('success-modal');
                    modal.style.display = 'flex';

                    setTimeout(() => {
                        if (role === 'admin' || role === 'principal') {
                            window.location.href = "{{ route('principal.dashboard') }}";
                        } else if (role === 'teacher') {
                            window.location.href = "{{ route('home') }}";
                        } else if (role === 'mswd') {
                            window.location.href = "{{ route('mswd.dashboard') }}";
                        } else {
                            window.location.href = "{{ route('home') }}";
                        }
                    }, 1000);

                } catch (error) {
                    console.error("Login Error:", error);

                    emailInput.style.border = '2px solid red';
                    passwordInput.style.border = '2px solid red';
                    message.style.color = 'red';

                    if (error.code === 'not-admin') {
                        message.textContent =
                            "Access denied. Your account is not registered as an admin.";
                    } else if (error.code === 'auth/user-not-found' || error.code ===
                        'auth/wrong-password') {
                        message.textContent = "Invalid email or password.";
                    } else {
                        message.textContent = "Login failed. Please try again.";
                    }
                }
            });
        });
    </script>

</body>

</html>
