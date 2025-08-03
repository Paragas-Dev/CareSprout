<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Admin Management</title>
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principalsidebar.css') }}">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>
<div style="display: flex;">
    @include('partials.principal-sidebar')
    <div class="main-content-wrapper">
        <header>
            @include('partials.header')
            <div class="hamburger-menu" onclick="toggleSidebar(this)">
                <i class="fas fa-bars"></i>
            </div>
        </header>
        <div class="container">
            <div class="card">
                <h2>Add New Administrator</h2>
                <form id="addAdminForm">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" id="adminName" name="name" placeholder="Enter full name" required>
                        </div>
                        <div class="form-group">
                            <label>Email Address</label>
                            <input type="email" id="adminEmail" name="email" placeholder="Enter email" required>
                        </div>
                        <div class="form-group">
                            <label>Role</label>
                            <select id="adminRole" name="role" required>
                                <option value="" disabled selected>Select Role</option>
                                <option>Teacher</option>
                                <option>MSWD Officer</option>
                            </select>
                        </div>
                        <div class="form-group" style="position: relative;">
                            <label>Password</label>
                            <input type="password" id="adminPassword" name="password" placeholder="Enter password"
                                required>
                            <span class="toggle-password" onclick="togglePassword()"
                                style="position: absolute; top: 36px; right: 10px; cursor: pointer;">
                                <i id="togglePasswordIcon" class="fa fa-eye"></i>
                            </span>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit">Add Admin</button>
                    </div>
                </form>
            </div>
            <div class="existing-card">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                    <h2 style="margin: 0;">Existing Administrators</h2>
                    <input type="text" id="adminSearch" class="admin-search"
                        placeholder="Search by name, email, or role">
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email Address</th>
                            <th>Role</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="adminTableBody">

                    </tbody>
                </table>
                <div id="pagination" class="pagination-container"></div>
            </div>
        </div>
    </div>
</div>
    <!-- Edit Modal -->
    <div id="editAdminModal" class="modal" style="display:none;">
        <div class="modal-content">
            <span class="close" onclick="closeEditModal()">&times;</span>
            <h2>Edit Administrator</h2>
            <form id="editAdminForm">
                <input type="hidden" id="editAdminUid">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" id="editAdminName" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" id="editAdminEmail" disabled>
                </div>
                <div class="form-group">
                    <label>Role</label>
                    <select id="editAdminRole" required>
                        <option value="Teacher">Teacher</option>
                         <option value="MSWD Officer">MSWD Officer</option>
                    </select>
                </div>
                <button type="submit" style="margin-top: 15px;">Save Changes</button>
            </form>
        </div>
    </div>
    <!-- Success Modal -->
    <div id="successModal" class="modal" style="display: none;">
        <div class="modal-content">
            <span class="close" onclick="closeModal('successModal')">&times;</span>
            <h2>Success</h2>
            <p id="successMessage">Operation completed successfully.</p>
        </div>
    </div>

    <!-- Error Modal -->
    <div id="errorModal" class="modal" style="display: none;">
        <div class="modal-content">
            <span class="close" onclick="closeModal('errorModal')">&times;</span>
            <h2>Error</h2>
            <p id="errorMessage">An error occurred.</p>
        </div>
    </div>

    <!-- Scripts -->
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        window.addEventListener('firebaseReady', function() {
            const db = window.db;
            const auth = window.auth;

            let adminData = [];
            let currentPage = 1;
            const itemsPerPage = 10;

            function renderTable(data) {
                const tableBody = document.getElementById("adminTableBody");
                tableBody.innerHTML = "";
                const start = (currentPage - 1) * itemsPerPage;
                const end = start + itemsPerPage;
                const currentItems = data.slice(start, end);

                currentItems.forEach(admin => {
                    const row = `
                        <tr>
                            <td>${admin.displayName}</td>
                            <td>${admin.email}</td>
                            <td>${admin.role}</td>
                            <td>
                                <a href="#" onclick="openEditModal('${admin.uid}', '${admin.displayName}', '${admin.email}', '${admin.role}')">Edit</a>
                                | <a href="#" class="delete" onclick="deleteAdmin('${admin.uid}')">Delete</a>

                            </td>
                        </tr>`;
                    tableBody.innerHTML += row;
                });

                renderPagination(data.length);
            }

            function renderPagination(totalItems) {
                const pagination = document.getElementById("pagination");
                pagination.innerHTML = "";
                const totalPages = Math.ceil(totalItems / itemsPerPage);

                for (let i = 1; i <= totalPages; i++) {
                    const btn = document.createElement('button');
                    btn.textContent = i;
                    btn.className = (i === currentPage) ? 'active' : '';
                    btn.onclick = () => {
                        currentPage = i;
                        renderTable(adminData);
                    };
                    pagination.appendChild(btn);
                }
            }

            function loadAdmins() {
                auth.onAuthStateChanged(currentUser => {
                    if (!currentUser) return;

                    const currentUid = currentUser.uid;

                    db.collection("admin").orderBy("createdAt", "desc").onSnapshot(snapshot => {
                        adminData = [];
                        snapshot.forEach(doc => {
                            const data = doc.data();
                            if (doc.id !== currentUid) {
                                adminData.push({
                                    ...data,
                                    uid: doc.id
                                });
                            }
                        });
                        renderTable(adminData);
                    });
                });
            }

            // search filter function
            document.getElementById("adminSearch").addEventListener("input", function() {
                const query = this.value.toLowerCase();
                const filtered = adminData.filter(admin =>
                    admin.displayName.toLowerCase().includes(query) ||
                    admin.email.toLowerCase().includes(query) ||
                    admin.role.toLowerCase().includes(query)
                );
                currentPage = 1;
                renderTable(filtered);
            });

            document.getElementById("addAdminForm").addEventListener("submit", async function(e) {
                e.preventDefault();

                const name = document.getElementById('adminName').value.trim();
                const email = document.getElementById('adminEmail').value.trim();
                const role = document.getElementById('adminRole').value;
                const password = document.getElementById('adminPassword').value;

                if (!name || !email || !role || !password) return alert("Please fill in all fields.");

                const secondaryApp = firebase.initializeApp(firebase.app().options, "Secondary");

                try {
                    const cred = await secondaryApp.auth().createUserWithEmailAndPassword(email,
                        password);
                    await db.collection("admin").doc(cred.user.uid).set({
                        displayName: name,
                        name: name,
                        email: email,
                        role: role,
                        createdAt: firebase.firestore.FieldValue.serverTimestamp()
                    });
                    showSuccessModal("Admin added successfully!");
                    addAdminForm.reset();
                } catch (err) {
                    showErrorModal("Error: " + err.message);
                } finally {
                    await secondaryApp.auth().signOut();
                    await secondaryApp.delete();
                }
            });

            document.getElementById("editAdminForm").addEventListener("submit", async function(e) {
                e.preventDefault();
                const uid = document.getElementById("editAdminUid").value;
                const name = document.getElementById("editAdminName").value;
                const role = document.getElementById("editAdminRole").value;

                try {
                    await db.collection("admin").doc(uid).update({
                        displayName: name,
                        name: name,
                        role: role,
                        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
                    });
                    showSuccessModal("Admin updated successfully!");
                    closeEditModal();
                } catch (error) {
                    console.error("Error updating admin:", error);
                }
            });

            loadAdmins();
        });

        async function deleteAdmin(uid) {
            const confirmDelete = confirm("Are you sure you want to delete this admin?");
            if (!confirmDelete) return;

            try {
                const response = await fetch(`/admin/delete/${uid}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Content-Type': 'application/json'
                    }
                });

                if (!response.ok) {
                    const error = await response.json();
                    console.error('Error:', error);
                    throw new Error('Failed to delete admin');
                }
                location.reload();
                fetchAdmins();
                showSuccessModal("Admin deleted successfully!");

            } catch (error) {
                console.error(error);
                showErrorModal("Error deleting admin.");
            }
        }

        function togglePassword() {
            const password = document.getElementById("adminPassword");
            const icon = document.getElementById("togglePasswordIcon");
            if (password.type === "password") {
                password.type = "text";
                icon.classList.replace("fa-eye", "fa-eye-slash");
            } else {
                password.type = "password";
                icon.classList.replace("fa-eye-slash", "fa-eye");
            }
        }

        function openEditModal(uid, name, email, role) {
            document.getElementById("editAdminUid").value = uid;
            document.getElementById("editAdminName").value = name;
            document.getElementById("editAdminEmail").value = email;
            document.getElementById("editAdminRole").value = role;
            document.getElementById("editAdminModal").style.display = "flex";
        }

        function closeEditModal() {
            document.getElementById("editAdminModal").style.display = "none";
        }

        function showSuccessModal(message) {
            const modal = document.getElementById('successModal');
            document.getElementById('successMessage').innerText = message;
            modal.style.display = 'flex';

            setTimeout(() => {
                modal.style.display = 'none';
            }, 2000);
        }

        function showErrorModal(message) {
            const modal = document.getElementById('errorModal');
            document.getElementById('errorMessage').innerText = message;
            modal.style.display = 'flex';

            setTimeout(() => {
                modal.style.display = 'none';
            }, 2000);
        }

        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
    </script>
</body>

</html>
