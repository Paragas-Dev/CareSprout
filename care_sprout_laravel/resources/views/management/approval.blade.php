<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/approval.css') }}">
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>
</head>
<body style="display: flex; min-height: 100vh; margin: 0;">
  @include('partials.sidebar')
  <div class="main-content-wrapper">
    <div style="width: 100%;">
      @include('partials.header')
      <div class="hamburger-menu" onclick="toggleSidebar(this)">
          <i class="fas fa-bars"></i>
      </div>
    </div>
    <div class="main-content">
      <div class="approved-container">
          <div class="table-controls">
            <input type="text" id="searchInput" placeholder="🔍 Search users...">
            <select id="statusFilter">
              <option value="">All Status</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
        <table>
          <thead>
            <tr>
              <th>Student Name</th>
              <th>Disabilities <i class="fas fa-caret-down"></i></th>
              <th>Parent Name</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="studentTable">
            <!-- Data will be populated by JavaScript -->
          </tbody>
        </table>
        <div id="loadingMessage" style="text-align: center; padding: 20px; display: none;">
          <i class="fas fa-spinner fa-spin"></i> Loading users...
        </div>
        <div id="noDataMessage" style="text-align: center; padding: 20px; display: none;">
          <i class="fas fa-info-circle"></i> No users found
        </div>
      </div>
    </div>
  </div>

  <!-- Centralized Firebase Configuration -->
  <script src="{{ asset('js/firebase-config.js') }}"></script>

  <script>
    // Wait for Firebase to be ready
    window.addEventListener('firebaseReady', function() {
      const db = window.db;
      
      // Load users from Firestore
      function loadPendingUsers() {
      const loadingMessage = document.getElementById('loadingMessage');
      const noDataMessage = document.getElementById('noDataMessage');
      const studentTable = document.getElementById('studentTable');
      
      loadingMessage.style.display = 'block';
      studentTable.innerHTML = '';
      noDataMessage.style.display = 'none';

      db.collection('users')
        .where('approved', '==', false)
        .get()
        .then((querySnapshot) => {
          const users = [];

          querySnapshot.forEach((doc) => {
            const data = doc.data();
            users.push({
              id: doc.id,
              userName: data.userName || 'N/A',
              disabilities: data.disability || 'None',
              parentName: data.parentName || 'N/A',
              approved: data.approved ?? false,
            });
          });
          
          
          if (users.length > 0) {
            displayUsers(users);
          } else {
            noDataMessage.style.display = 'block';
          }

          loadingMessage.style.display = 'none';
        })
        .catch((error) => {
          console.error("Error fetching users:", error);
          loadingMessage.style.display = 'none';
          noDataMessage.style.display = 'block';
          noDataMessage.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Error loading users';
        });
    }

    // Display users in the table
    function displayUsers(users) {
      const studentTable = document.getElementById('studentTable');
      studentTable.innerHTML = '';

      users.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = `
          <td>${user.userName}</td>
          <td>${user.disability}</td>
          <td>${user.parentName}</td>
          <td>
            <span class="status-badge status-pending">Pending</span>
          </td>
          <td>
            <div class="action-buttons">
              <button class="btn-approve" onclick="updateUserStatus('${user.id}', true)">
                <i class="fas fa-check"></i> Approve
              </button>
              <button class="btn-reject" onclick="updateUserStatus('${user.id}', false)">
                <i class="fas fa-times"></i> Reject
              </button>
            </div>
          </td>
        `;
        studentTable.appendChild(row);
      });
    }

    // Update user status
    function updateUserStatus(userId, approve) {
      db.collection('users').doc(userId).update({
        approved: approve,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      })
      .then(() => {
        showNotification(`User ${approve ? 'approved' : 'rejected'} successfully`, 'success');
        loadPendingUsers(); // Refresh table
      })
      .catch((error) => {
        console.error("Error updating user status:", error);
        showNotification('Failed to update user status', 'error');
      });
    }

    // View user details
    function viewUserDetails(userId) {
      const user = allUsers.find(u => u.id === userId);
      if (user) {
        alert(`User Details:\nName: ${user.name}\nEmail: ${user.email}\nParent: ${user.parentName}\nStatus: ${user.status}\nDisabilities: ${user.disabilities.join(', ') || 'None'}`);
      }
    }

    // Show notification
    function showNotification(message, type) {
      const notification = document.createElement('div');
      notification.className = `notification notification-${type}`;
      notification.innerHTML = `<i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i> ${message}`;
      document.body.appendChild(notification);
      setTimeout(() => notification.remove(), 3000);
    }
    document.addEventListener('DOMContentLoaded', function() {
      loadPendingUsers();
    });

    function goTo(url) {
    window.location.href = url;
    }
    function toggleSidebar(element) {
      const sidebar = document.querySelector('.sidebar');
      sidebar.classList.toggle('open');

      // Toggle the icon between bars and times
      const icon = element.querySelector('i');
      if (sidebar.classList.contains('open')) {
        icon.classList.remove('fa-bars');
        icon.classList.add('fa-times');
      } else {
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
      }
    }
  });
  </script>
</body>
</html>
