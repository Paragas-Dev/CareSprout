<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Announcement Board</title>
    <link rel="stylesheet" href="{{ asset('css/ano.css') }}">
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
                <div class="card announcement-form">
                    <h2>Post New Announcement</h2>
                    <form onsubmit="event.preventDefault(); postAnnouncement();">
                        <input type="text" id="announcement-title" name="title" placeholder="Enter title..." required>
                        <textarea id="announcement-content" name="content" placeholder="Write your announcement here..." rows="5"
                            required></textarea>
                        <button type="submit">+ Post Announcement</button>
                    </form>
                </div>

                <div class="card announcement-list">
                    <h2>Recent Announcements</h2>
                    <div class="table-wrapper">
                        <table id="announcements-table">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Posted by</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="4">Loading announcements...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="successModal" class="modal">
        <div class="modal-content success">
            <span class="close" onclick="closeModal('successModal')">&times;</span>
            <p>✅ Announcement posted successfully!</p>
        </div>
    </div>
    <div id="errorModal" class="modal">
        <div class="modal-content error">
            <span class="close" onclick="closeModal('errorModal')">&times;</span>
            <p>❌ Failed to post announcement. Please try again.</p>
        </div>
    </div>
    <div id="editAnnouncementModal" class="modal">
        <div class="modal-content edit-modal-content">
            <span class="close" onclick="closeModal('editAnnouncementModal')">&times;</span>
            <h3>Edit Announcement</h3>
            <input type="text" id="edit-announcement-title" placeholder="Edit title..." required>
            <textarea id="edit-announcement-content" rows="5" placeholder="Edit content..." required></textarea>
            <button onclick="updateAnnouncement()">Save Changes</button>
        </div>
    </div>
    <div id="viewAnnouncementModal" class="modal">
        <div class="modal-content letter-style">
            <span class="close" onclick="closeModal('viewAnnouncementModal')">&times;</span>
            <div class="letter-header">
                <h2 id="viewTitle">[Title]</h2>
                <p><strong>Posted By:</strong> <span id="viewAdminName"></span></p>
                <p><strong>Date:</strong> <span id="viewDate"></span></p>
            </div>
            <hr>
            <div class="letter-body" id="viewContent">

            </div>
            <hr>
        </div>
    </div>

    <!-- Scripts -->
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script>
        function showModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.style.display = "block";

            if (modalId === 'editAnnouncementModal' || modalId === 'viewAnnouncementModal') {
                document.body.classList.add('modal-open');
            }

            if (modalId === 'successModal' || modalId === 'errorModal') {
                setTimeout(() => closeModal(modalId), 2000);
            }
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.style.display = "none";

            if (modalId === 'editAnnouncementModal' || modalId === 'viewAnnouncementModal') {
                document.body.classList.remove('modal-open');
            }
        }

        window.onclick = function(event) {
            const dismissibleModals = ['successModal', 'errorModal'];
            dismissibleModals.forEach(id => {
                const modal = document.getElementById(id);
                if (event.target === modal) {
                    modal.style.display = "none";
                }
            });
        };

        let editingAnnouncementId = null;
        let announcements = [];
        let currentPage = 1;
        const rowsPerPage = 10;

        window.addEventListener('DOMContentLoaded', function() {
            window.addEventListener('firebaseReady', function() {

                const db = window.db;
                const auth = window.auth;

                window.postAnnouncement = async function() {
                    const title = document.getElementById('announcement-title').value;
                    const content = document.getElementById('announcement-content').value;
                    const user = auth.currentUser;

                    if (!title || !content) {
                        alert('Please fill in both title and content.');
                        return;
                    }

                    try {
                        const adminDoc = await db.collection('admin').doc(user.uid).get();
                        const postedBy = adminDoc.exists ? adminDoc.data().name || adminDoc.data()
                            .displayName : 'Unknown';
                        const timestamp = new firebase.firestore.FieldValue.serverTimestamp();

                        await db.collection('announcements').add({
                            title: title,
                            content: content,
                            adminName: postedBy,
                            adminId: user.uid,
                            createdAt: timestamp,
                        });

                        showModal('successModal');
                        document.getElementById('announcement-title').value = '';
                        document.getElementById('announcement-content').value = '';
                        await loadAnnouncements();

                    } catch (error) {
                        console.error("Error posting announcement:", error);
                        showModal('errorModal');
                    }
                };

                async function loadAnnouncements() {
                    try {
                        const snapshot = await db.collection('announcements')
                            .orderBy('createdAt', 'desc')
                            .get();

                        announcements = snapshot.docs.map(doc => ({
                            id: doc.id,
                            ...doc.data()
                        }));

                        renderTable();
                    } catch (error) {
                        console.error("Error fetching announcements:", error);
                    }
                }

                function renderTable() {
                    const tableBody = document.querySelector('#announcements-table tbody');
                    tableBody.innerHTML = "";

                    const start = (currentPage - 1) * rowsPerPage;
                    const end = start + rowsPerPage;
                    const paginationAnnouncements = announcements.slice(start, end);

                    if (paginationAnnouncements.length === 0) {
                        tableBody.innerHTML = `<tr><td colspan="4">No announcements found.</td></tr>`;
                    } else {
                        paginationAnnouncements.forEach(a => {
                            const date = a.createdAt?.toDate().toLocaleString() || 'N/A';
                            tableBody.innerHTML += `
                            <tr>
                                    <td>${a.title}</td>
                                    <td>${a.adminName || 'Unknown'}</td>
                                    <td>${date}</td>
                                    <td>
                                        <button onclick="viewAnnouncement('${a.id}')">View</button>
                                        <button onclick="editAnnouncement('${a.id}', \`${a.title}\`, \`${a.content}\`)">Edit</button>
                                        <button onclick="deleteAnnouncement('${a.id}')">Delete</button>
                                    </td>
                                </tr>
                            `;
                        });
                    }
                    renderPagination();
                }

                function renderPagination() {
                    let totalPages = Math.ceil(announcements.length / rowsPerPage);
                    let paginationHTML = `<div class="pagination">`;

                    for (let i = 1; i <= totalPages; i++) {
                        paginationHTML +=
                            `<button onclick="goToPage(${i})" ${i === currentPage ? 'class="active"' : ''}>${i}</button>`;
                    }

                    paginationHTML += `</div>`;

                    const wrapper = document.querySelector('.announcement-list');
                    const oldPagination = wrapper.querySelector('.pagination');
                    if (oldPagination) oldPagination.remove();
                    wrapper.insertAdjacentHTML('beforeend', paginationHTML);
                }

                window.goToPage = function(page) {
                    currentPage = page;
                    renderTable();
                };

                window.deleteAnnouncement = async function(id) {
                    if (!confirm("Are you sure you want to delete this announcement?")) return;
                    try {
                        await db.collection('announcements').doc(id).delete();
                        announcements = announcements.filter(a => a.id !== id);
                        renderTable();
                        showModal('successModal');
                    } catch (error) {
                        console.error("Error deleting announcement:", error);
                        showModal('errorModal');
                    }
                };

                window.editAnnouncement = function (id, title, content) {
                    editingAnnouncementId = id;
                    document.getElementById('edit-announcement-title').value = title;
                    document.getElementById('edit-announcement-content').value = content;
                    showModal('editAnnouncementModal');
                };

                window.updateAnnouncement = async function () {
                    const newTitle = document.getElementById('edit-announcement-title').value;
                    const newContent = document.getElementById('edit-announcement-content').value;

                    if (!editingAnnouncementId || !newTitle || !newContent) {
                        showModal('errorModal');
                        return;
                    }

                    try {
                        await db.collection('announcements').doc(editingAnnouncementId).update({
                            title: newTitle,
                            content: newContent,
                            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
                        });
                        showModal('successModal');
                        closeModal('editAnnouncementModal');
                        await loadAnnouncements();
                    } catch (error) {
                        console.error("Error updating announcement:", error);
                        showModal('errorModal');
                    }
                };

                window.viewAnnouncement = async function (id) {
                    try {
                        const doc = await db.collection('announcements').doc(id).get();
                        if (!doc.exists) return showModal('errorModal');

                        const data = doc.data();
                        document.getElementById('viewDate').innerText = data.createdAt?.toDate().toLocaleString() || 'N/A';
                        document.getElementById('viewAdminName').textContent = data.adminName || 'Unknown';
                        document.getElementById('viewTitle').innerText = data.title;
                        document.getElementById('viewContent').innerText = data.content;

                        showModal('viewAnnouncementModal');
                    } catch (error) {
                        console.error("Error viewing announcement:", error);
                        showModal('errorModal');
                    }
                };

                loadAnnouncements();
            });
        });
    </script>
</body>

</html>
