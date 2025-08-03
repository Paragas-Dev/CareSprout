<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/students.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principalsidebar.css') }}">
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
            <div class="container student-summary-container">
                <section class="summary">
                    <h2>Student Summary</h2>
                    <div class="cards">
                        <div class="card blue">
                            <p>Total SPED Students</p>
                            <h1 id="total-sped-students-value">Loading...</h1>
                            <span class="icon">Icon</span>
                        </div>
                        <div class="card green">
                            <p>E-learning Engagement</p>
                            <h1>92%</h1>
                            <span class="icon">Icon</span>
                        </div>
                    </div>
                    <div class="filters">
                        <input type="text" id="searchInput" placeholder="Search Student">
                        <select id="disabilityFilter">
                            <option>All</option>
                            <option>Speech Disorder</option>
                            <option>Physical Disability</option>
                            <option>Visual Impairment</option>
                            <option>Hearing Impairment</option>
                            <option>Interpersonal Behavioral Disorder</option>
                            <option>Others</option>
                        </select>
                        <input type="text" id="otherDisabilityFilterInput" placeholder="Specify Disability for Filter" style="display: none;">
                        <button class="apply" onclick="applyFilters()">Apply Filters</button>
                    </div>
                </section>
            </div>

            <div class="container student-records-container">
                <section class="records">
                    <h2>Student Records</h2>
                    <button class="add" onclick="openStudentModal()">+ Add new Student</button>
                    <table>
                        <div id="student-loader" class="loader-overlay" style="display: none;">
                            <div class="spinner"></div>
                        </div>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Disability</th>
                                <th>Guardian's Name</th>
                                <th>Avg. Progress</th>
                                <th>Remarks</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                    <div class="pagination-controls" style="display: flex; justify-content: flex-start; margin-top: 10px;">
                        <button onclick="prevPage()" id="prevBtn" disabled style="margin-right: 5px;">Previous</button>
                        <button onclick="nextPage()" id="nextBtn">Next</button>
                    </div>
                </section>
            </div>
        </div>
    </div>
    <div id="studentModal" class="modal">
        <div class="modal-content">
            <div id="successPopup" class="success-popup" style="display: none;">
                Student added successfully!
            </div>
            <span class="close" onclick="closeStudentModal()">&times;</span>
            <h2>Add New Student</h2>
            <form id="addStudentForm">
                <input type="text" name="userName" placeholder="Full Name" required>
                <input type="date" name="birthYear" required>

                <select name="disability" id="disabilitySelect" required>
                    <option value="">Select Disability</option>
                    <option value="Visual Impairment">Visual Impairment</option>
                    <option value="Hearing Impairment">Hearing Impairment</option>
                    <option value="Physical Disability">Physical Disability</option>
                    <option value="Speech Disorder">Speech Disorder</option>
                    <option value="Interpersonal Behavioral Disorder">Interpersonal Behavioral Disorder</option>
                    <option value="Others">Others</option>
                </select>

                <input type="text" name="otherDisability" id="otherDisabilityInput" placeholder="Specify Disability" style="display: none;">

                <input type="email" name="email" placeholder="Email" required>
                <input type="password" name="password" placeholder="Password" required>
                <input type="text" name="gender" placeholder="Gender" required>
                <input type="text" name="homeAddress" placeholder="Home Address" required>
                <input type="text" name="parentName" placeholder="Parent Name" required>
                <input type="text" name="phone" placeholder="Phone" required>
                <input type="text" name="LRN" placeholder="LRN" required>
                <button type="submit">Add Student</button>
            </form>
        </div>
    </div>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>

        function openStudentModal() {
            document.getElementById('studentModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeStudentModal() {
            document.getElementById('studentModal').style.display = 'none';
            document.body.style.overflow = '';

            const form = document.getElementById('addStudentForm');
            form.reset();

            const disabilitySelect = document.getElementById('disabilitySelect');
            const otherDisabilityInput = document.getElementById('otherDisabilityInput');
            disabilitySelect.value = '';
            otherDisabilityInput.style.display = 'none';
            otherDisabilityInput.removeAttribute('required');
            otherDisabilityInput.value = '';
        }

        let pageSize = 10;
        let lastVisible = null;
        let firstVisible = null;
        let prevSnapshots = [];

        function nextPage() {
            const searchTerm = document.getElementById('searchInput').value.trim();
            let selectedDisability = document.getElementById('disabilityFilter').value;
            if (selectedDisability === 'Others') {
                selectedDisability = document.getElementById('otherDisabilityFilterInput').value.trim();
            }
            renderStudentRecords(searchTerm, disability, 'next');
        }

        function prevPage() {
            const searchTerm = document.getElementById('searchInput').value.trim();
            let selectedDisability = document.getElementById('disabilityFilter').value;
            if (selectedDisability === 'Others') {
                selectedDisability = document.getElementById('otherDisabilityFilterInput').value.trim();
            }
            renderStudentRecords(searchTerm, disability, 'prev');
        }

        function applyFilters(direction = 'start') {
                const searchTerm = document.getElementById('searchInput').value.trim();
                const disabilityFilterSelect = document.getElementById('disabilityFilter');
                const otherDisabilityFilterInput = document.getElementById('otherDisabilityFilterInput');

                let selectedDisability = disabilityFilterSelect? disabilityFilterSelect.value : 'All';
                if (selectedDisability === 'Others' && otherDisabilityFilterInput) {
                    selectedDisability = otherDisabilityFilterInput.value.trim();
                }
                if (direction === 'start') {
                    prevSnapshots = [];
                }
                renderStudentRecords(searchTerm, selectedDisability, direction);
            }


        window.addEventListener('firebaseReady', function() {
        const db = window.db;
        const auth = window.auth;

        // student count
        function fetchSpedEnrollees() {
            const studentCountElement = document.getElementById('total-sped-students-value');
            if (!studentCountElement) {
                console.error("SPED enrollment value element not found!");
                return;
            }
            studentCountElement.textContent = 'Loading...';

            db.collection('users')
                .where('status', '==', 'approved')
                .get()
                .then(snapshot => {
                    const count = snapshot.size;
                    studentCountElement.textContent = count;
                })
                .catch(error => {
                    console.error("Error fetching SPED enrollment:", error);
                    studentCountElement.textContent = 'Error';
                });
            }
            fetchSpedEnrollees();
            applyFilters();

            const disabilitySelect = document.getElementById('disabilitySelect');
            const otherDisabilityInput = document.getElementById('otherDisabilityInput');

            disabilitySelect.addEventListener('change', function() {
                if (this.value === 'Others') {
                    otherDisabilityInput.style.display = 'block';
                    otherDisabilityInput.setAttribute('required', 'required');
                    otherDisabilityInput.focus();
                } else {
                    otherDisabilityInput.style.display = 'none';
                    otherDisabilityInput.removeAttribute('required');
                    otherDisabilityInput.value = '';
                }
                if (this.value !== 'Others') {
                    applyFilters();
                }
            });

            // Adding of ne student
            const form = document.getElementById('addStudentForm');
            form.addEventListener('submit', async (e) => {
                e.preventDefault();

                const formData = new FormData(form);
                const data = Object.fromEntries(formData.entries());

                let finalDisability = data.disability;
                if (data.disability === 'Others') {
                    finalDisability = data.otherDisability.trim();
                }

                if (finalDisability === '' || finalDisability === 'Select Disability') {
                    alert('Please specify a valid disability.');
                    return;
                }

                if (data.disability === 'Others' && !data.otherDisability.trim()) {
                    alert('Please specify the disability.');
                    return;
                }

                try {
                    if (!auth) {
                        console.error("Firebase Auth is not initialized.");
                        alert("Firebase Auth is not available. Please check console for errors.");
                        return;
                    }
                    if (!db) {
                        console.error("Firebase Firestore is not initialized.");
                        alert("Firebase Firestore is not available. Please check console for errors.");
                        return;
                    }

                    const userCredential = await auth.createUserWithEmailAndPassword(data.email, data.password);
                    const user = userCredential.user;

                    console.log("Created new student UID:", user.uid);

                    await db.collection('users').doc(user.uid).set({
                        userName: data.userName,
                        birthYear: data.birthYear,
                        disability: finalDisability,
                        email: data.email,
                        gender: data.gender,
                        homeAddress: data.homeAddress,
                        parentName: data.parentName,
                        parentNameLowercase: data.parentName.toLowerCase(),
                        phone: data.phone,
                        LRN: data.LRN,
                        status: 'approved',
                        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                        uid: user.uid
                    });

                    const successPopup = document.getElementById('successPopup');

                    successPopup.style.display = 'block';
                    form.reset();

                    setTimeout(() => {
                        successPopup.style.display = 'none';
                        closeStudentModal();
                        renderStudentRecords();
                    }, 2000);

                } catch (error) {
                    console.error("Error adding student:", error);
                    alert('Error adding student: ' + error.message);
                }
            });
        });

        // Student Records table
        function renderStudentRecords(searchTerm = '', disability = 'All', direction = 'start') {
            console.log('renderStudentRecords called with:', { searchTerm, disability, direction });

            const tbody = document.querySelector('.student-records-container tbody');
            const loader = document.getElementById('student-loader');
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');

            loader.style.display = 'block';
            tbody.innerHTML = '';

            let query = db.collection('users')
                .where('status', '==', 'approved')
                .orderBy('userName')

            if (disability !== 'All' && disability.trim() !== '') {
                query = query.where('disability', '==', disability);
            }

            if (direction === 'next' && lastVisible) {
                query = query.startAfter(lastVisible);
            } else if (direction === 'prev' && prevSnapshots.length > 0) {
                query = query.endBefore(firstVisible);
                query = query.limitToLast(pageSize);
            }

            query.limit(pageSize).get().then(snapshot => {
                loader.style.display = 'none';
                let docs = snapshot.docs;
                if (direction === 'prev') {
                    docs = docs.reverse();
                }

                let filtered = docs.filter(doc => {
                    const data = doc.data();
                    const nameMatch = data.userName?.toLowerCase().includes(searchTerm.toLowerCase());
                    const disabilityMatch = (disability === 'All' || disability.trim() === '') ? true : data.disability === disability;
                    return nameMatch && disabilityMatch;
                });

                if (filtered.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">No students found.</td></tr>';
                    document.getElementById('nextBtn').disabled = true;
                    document.getElementById('prevBtn').disabled = true;
                    return;
                }

                firstVisible = docs[0];
                lastVisible = docs[docs.length - 1];

                if (direction === 'next') {
                    prevSnapshots.push(firstVisible);
                } else if (direction === 'prev' && prevSnapshots.length > 0) {
                    prevSnapshots.pop();
                }

                document.getElementById('prevBtn').disabled = prevSnapshots.length === 0;

                db.collection('users')
                    .where('status', '==', 'approved')
                    .orderBy('userName')
                    .startAfter(lastVisible)
                    .limit(1)
                    .get().then(nextSnapshot => {
                        document.getElementById('nextBtn').disabled = nextSnapshot.empty;
                    });


                filtered.forEach(doc => {
                    const data = doc.data();
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${data.userName || 'N/A'}</td>
                        <td>${data.disability || 'N/A'}</td>
                        <td>${data.parentName || 'N/A'}</td>
                        <td></td>
                        <td></td>
                        <td><a href="#">View Details</a></td>
                    `;
                    tbody.appendChild(row);
                });
            }).catch(error => {
                console.error("Error paginating records:", error);
                tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color: red;">Error loading students.</td></tr>';
            }).finally(() => {
                loader.style.display = 'none';
            });
        }

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
