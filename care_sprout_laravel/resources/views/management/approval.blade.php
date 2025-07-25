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
              <th>LRN</th>
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
        <div id="pagination-controls" class="pagination-controls"></div>
        <div id="loadingMessage" style="text-align: center; padding: 20px; display: none;">
          <i class="fas fa-spinner fa-spin"></i> Loading users...
        </div>
        <div id="noDataMessage" style="text-align: center; padding: 20px; display: none;">
          <i class="fas fa-info-circle"></i> No users found
        </div>
      </div>
    </div>
  </div>

  <script src="{{ asset('js/firebase-config.js') }}"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const tableBody = document.getElementById('studentTable');
      const loadingMessage = document.getElementById('loadingMessage');
      const noDataMessage = document.getElementById('noDataMessage');
      const searchInput = document.getElementById('searchInput');
      const statusFilter = document.getElementById('statusFilter');
      let allUsers = [];
      let currentPage = 1;
      const rowsPerPage = 10;

      window.addEventListener('firebaseReady', async () => {
        console.log('Firebase ready event fired!');
        loadingMessage.style.display = 'block';
        try {
          const snapshot = await db.collection('users').get();
          allUsers = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          renderTable();
        } catch (error) {
          console.error('Error loading users:', error);
          noDataMessage.style.display = 'block';
        } finally {
          loadingMessage.style.display = 'none';
        }
      });

      function renderTable() {
        const search = searchInput.value.toLowerCase();
        const filterStatus = statusFilter.value;

        const filtered = allUsers.filter(user => {
          const matchSearch = (
            user.userName?.toLowerCase().includes(search) ||
            user.LRN?.toLowerCase().includes(search) ||
            user.parentName?.toLowerCase().includes(search)
          );

          const matchStatus = filterStatus ? user.status === filterStatus : true;

          return matchSearch && matchStatus;
        });

        tableBody.innerHTML = '';

        if (filtered.length === 0) {
          noDataMessage.style.display = 'block';
          document.getElementById('pagination-controls').innerHTML = '';
          return;
        } else {
          noDataMessage.style.display = 'none';
        }

        // Pagination logic
        const totalPages = Math.ceil(filtered.length / rowsPerPage);
        if (currentPage > totalPages) currentPage = totalPages || 1;
        const startIdx = (currentPage - 1) * rowsPerPage;
        const endIdx = startIdx + rowsPerPage;
        const pageUsers = filtered.slice(startIdx, endIdx);

        pageUsers.forEach(user => {
          const row = document.createElement('tr');
          // Status badge
          let statusClass = 'status-pending';
          let statusText = 'Pending';
          if (user.status === 'approved') {
            statusClass = 'status-approved';
            statusText = 'Approved';
          } else if (user.status === 'rejected') {
            statusClass = 'status-rejected';
            statusText = 'Rejected';
          }
          // Action buttons
          const isApproved = user.status === 'approved';
          const approveBtn = `<button class="btn-approve" onclick="updateStatus('${user.id}', 'approved')"${isApproved ? ' disabled' : ''}>Approve</button>`;
          const rejectBtn = `<button class="btn-reject" onclick="updateStatus('${user.id}', 'rejected')"${isApproved ? ' disabled' : ''}>Reject</button>`;
          row.innerHTML = `
            <td>${user.LRN || '-'}</td>
            <td>${user.userName || '-'}</td>
            <td>${user.disability || '-'}</td>
            <td>${user.parentName || '-'}</td>
            <td><span class="status-badge ${statusClass}">${statusText}</span></td>
            <td>
              ${approveBtn}
              ${rejectBtn}
            </td>
          `;
          tableBody.appendChild(row);
        });

        const numEmptyRows = rowsPerPage - pageUsers.length;
        for (let i = 0; i < numEmptyRows; i++) {
          const emptyRow = document.createElement('tr');
          emptyRow.innerHTML = '<td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>';
          tableBody.appendChild(emptyRow);
        }

        // Pagination controls
        const pagination = document.getElementById('pagination-controls');
        pagination.innerHTML = '';
        if (totalPages > 1) {

          const leftArrow = document.createElement('button');
          leftArrow.textContent = '<';
          leftArrow.disabled = currentPage === 1;
          leftArrow.className = 'pagination-arrow';
          leftArrow.onclick = () => { currentPage--; renderTable(); };
          pagination.appendChild(leftArrow);

          for (let i = 1; i <= totalPages; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.textContent = i;
            pageBtn.className = 'pagination-page' + (i === currentPage ? ' active' : '');
            if (i === currentPage) pageBtn.disabled = true;
            pageBtn.onclick = () => { currentPage = i; renderTable(); };
            pagination.appendChild(pageBtn);
          }

          const rightArrow = document.createElement('button');
          rightArrow.textContent = '>';
          rightArrow.disabled = currentPage === totalPages;
          rightArrow.className = 'pagination-arrow';
          rightArrow.onclick = () => { currentPage++; renderTable(); };
          pagination.appendChild(rightArrow);
        }
      }

      // Approve / Reject logic
      window.updateStatus = async function(userId, newStatus) {
        try {
          await db.collection('users').doc(userId).update({ status: newStatus });
          allUsers = allUsers.map(user => user.id === userId ? { ...user, status: newStatus } : user);
          renderTable();
          alert(`User marked as ${newStatus}`);
        } catch (err) {
          console.error(`Error updating user status to ${newStatus}:`, err);
        }
      }

      searchInput.addEventListener('input', renderTable);
      statusFilter.addEventListener('change', renderTable);
      // Reset to first page on search/filter
      searchInput.addEventListener('input', () => { currentPage = 1; });
      statusFilter.addEventListener('change', () => { currentPage = 1; });
    });

    // Sidebar toggle
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
