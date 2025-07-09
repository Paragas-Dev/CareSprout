<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>
  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/reports.css') }}">
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
        <table>
          <thead>
            <tr>
              <th>Full Name</th>
              <th>Age</th>
              <th>Date of Birth</th>
              <th>Sex</th>
            </tr>
          </thead>

          <tbody id="studentTable">
            <tr style="background-color: #f5cccc;">
              <td>
                <div style="display: flex; align-items: center;">
                  <div style="width: 40px; height: 40px; background-color: #ccc; border-radius: 50%; margin-right: 10px;"></div>
                  John Doe
                </div>
              </td>
              <td>10</td>
              <td>May 10, 2019</td>
              <td>Male</td>
            </tr>
            <tr style="background-color: #d8d8f6;">
              <td>
                <div style="display: flex; align-items: center;">
                  <div style="width: 40px; height: 40px; background-color: #ccc; border-radius: 50%; margin-right: 10px;"></div>
                  Jane Smith
                </div>
              </td>
              <td>10</td>
              <td>May 10, 2019</td>
              <td>Female</td>
            </tr>
          </tbody>

        </table>
      </div>
    </div>
  </div>

  <script>
    function toggleDropdown(element) {
      element.classList.toggle("active");
    }

    // Optional: Close dropdown if clicked outside
    document.addEventListener("click", function(event) {
      const drop = document.querySelector(".drop");
      if (!drop.contains(event.target)) {
        drop.classList.remove("active");
      }
    });

    // Filter table rows by search input
    document.getElementById("searchInput").addEventListener("keyup", function () {
      const filter = this.value.toLowerCase();
      const rows = document.querySelectorAll("#studentTable tr");
      rows.forEach(row => {
        const cells = row.getElementsByTagName("td");
        const match = Array.from(cells).some(td => td.textContent.toLowerCase().includes(filter));
        row.style.display = match ? "" : "none";
      });
    });

    function approveStudent(button) {
      alert("Student Approved!");
      button.disabled = true;
      button.textContent = "Approved";
      button.style.backgroundColor = "#b2dfb2";
    }

    function deleteStudent(button) {
      const row = button.closest("tr");
      row.remove();
    }

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
  </script>
</body>
</html>
