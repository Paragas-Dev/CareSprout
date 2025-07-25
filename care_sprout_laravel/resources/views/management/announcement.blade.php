<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>
  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/announcement.css') }}">
</head>
<body>
  @include('partials.sidebar')
  <div style="flex: 1; display: flex; flex-direction: column; min-height: 100vh;">
    <div style="width: 100%;">
      @include('partials.header')
    </div>
    <div class="announcement-content-inner">
      <h2 class="announcement-title">Announcements</h2>
      <div class="announcement-list" id="announcement-list">
        <table class="announcement-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Posted by</th>
              <th>Date</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="announcement-tbody">
        <!-- Announcements will be loaded here -->
          </tbody>
        </table>
      </div>
      <!-- Modal for viewing announcement -->
      <div id="announcement-modal-overlay">
        <div id="announcement-modal">
          <button id="close-announcement-modal">&times;</button>
          <h3 id="modal-announcement-title"></h3>
          <div id="modal-announcement-content"></div>
        </div>

        <!-- Modal for editing announcement -->
        <div id="edit-announcement-modal" style="display:none;">
          <button id="close-edit-announcement-modal">&times;</button>
          <h3>Edit Announcement</h3>
          <form id="edit-announcement-form">
            <div>
              <label for="edit-title">Title</label><br>
              <input type="text" id="edit-title" name="title" required>
            </div>
            <div>
              <label for="edit-content">Content</label><br>
              <textarea id="edit-content" name="content" rows="4" required></textarea>
            </div>
            <button type="submit">Save</button>
          </form>
        </div>
      </div>
    </div>
  </div>
  <script src="{{ asset('js/firebase-config.js') }}"></script>
  <script>
    window.addEventListener('firebaseReady', function() {
      const db = window.db;


      // fetching announcements from firestore
      const announcementList = document.getElementById('announcement-list');
      const announcementTbody = document.getElementById('announcement-tbody');
      announcementTbody.innerHTML = '<tr><td colspan="5">Loading...</td></tr>';
      db.collection('announcements')
        .orderBy('createdAt', 'desc')
        .get()
        .then(snapshot => {
          announcementTbody.innerHTML = '';
          if (snapshot.empty) {
            announcementTbody.innerHTML = '<tr><td colspan="5">No Announcements found.</td></tr>';
            return;
          }
          snapshot.forEach(doc => {
            const data = doc.data();
            const tr = document.createElement('tr');
            tr.innerHTML = `
              <td>${data.title || 'Announcement'}</td>
              <td>${data.adminName || 'Admin'}</td>
              <td>${data.createdAt && data.createdAt.toDate ? data.createdAt.toDate().toISOString().split('T')[0] : ''}</td>
              <td colspan="2">
                <span class="announcement-actions">
                  <a href="#" class="view-announcement-link" data-id="${doc.id}">View</a>
                  <a href="#" class="edit-announcement-link" data-id="${doc.id}">Edit</a>
                  <a href="#" class="delete-announcement-link" data-id="${doc.id}">Delete</a>
                </span>
              </td>
            `;
            announcementTbody.appendChild(tr);
          });
          // View Annoucement Logic
          const modalOverlay = document.getElementById('announcement-modal-overlay');
          const modal = document.getElementById('announcement-modal');
          const closeModalBtn = document.getElementById('close-announcement-modal');
          const modalTitle = document.getElementById('modal-announcement-title');
          const modalContent = document.getElementById('modal-announcement-content');
          // Edit modal elements
          const editModal = document.getElementById('edit-announcement-modal');
          const closeEditModalBtn = document.getElementById('close-edit-announcement-modal');
          const editForm = document.getElementById('edit-announcement-form');
          const editTitleInput = document.getElementById('edit-title');
          const editContentInput = document.getElementById('edit-content');
          let editingAnnouncementId = null;
          document.querySelectorAll('.view-announcement-link').forEach(link => {
            link.addEventListener('click', async function(e) {
              e.preventDefault();
              const id = this.getAttribute('data-id');
              const docSnap = await db.collection('announcements').doc(id).get();
              const data = docSnap.data();
              modalTitle.textContent = data.title || 'Announcement';
              modalContent.textContent = data.content || '';
              modalOverlay.style.display = 'flex';
            });
          });
          closeModalBtn.addEventListener('click', function() {
            modalOverlay.style.display = 'none';
          });
          modalOverlay.addEventListener('click', function(e) {
            if (e.target === modalOverlay) {
              modalOverlay.style.display = 'none';
            }
          });
          // Delete Announcement Logic
          document.querySelectorAll('.delete-announcement-link').forEach(link => {
            link.addEventListener('click', async function(e) {
              e.preventDefault();
              const id = this.getAttribute('data-id');
              if (!confirm('Are you sure you want to delete this announcement?')) return;
              try {
                await db.collection('announcements').doc(id).delete();
                location.reload();
              } catch (e) {
                alert('Failed to delete announcement.');
                console.error(e);
              }
            });
          });
          // Edit Announcement Logic
          document.querySelectorAll('.edit-announcement-link').forEach(link => {
            link.addEventListener('click', async function(e) {
              e.preventDefault();
              const id = this.getAttribute('data-id');
              const docSnap = await db.collection('announcements').doc(id).get();
              const data = docSnap.data();
              editTitleInput.value = data.title || '';
              editContentInput.value = data.content || '';
              editingAnnouncementId = id;
              // Show edit modal, hide view modal if open
              modal.style.display = 'none';
              editModal.style.display = 'block';
              modalOverlay.style.display = 'flex';
            });
          });
          closeEditModalBtn.addEventListener('click', function() {
            editModal.style.display = 'none';
            modalOverlay.style.display = 'none';
          });
          editForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            if (!editingAnnouncementId) return;
            try {
              await db.collection('announcements').doc(editingAnnouncementId).update({
                title: editTitleInput.value,
                content: editContentInput.value
              });
              location.reload();
            } catch (err) {
              alert('Failed to update announcement.');
              console.error(err);
            }
          });
          // Hide edit modal if overlay is clicked (but not if modal itself is clicked)
          modalOverlay.addEventListener('click', function(e) {
            if (e.target === modalOverlay) {
              editModal.style.display = 'none';
              modalOverlay.style.display = 'none';
            }
          });
        })
        .catch(error => {
          announcementTbody.innerHTML = '<tr><td colspan="5">Error loading announcements.</td></tr>';
          console.error(error);
        });
    });
  </script>

</body>
</html>

