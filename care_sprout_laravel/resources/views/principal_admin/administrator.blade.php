<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Management</title>
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
     <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principal-sidebar.css') }}">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
      @include('partials.principal-sidebar')
     <div style="flex: 1; display: flex; flex-direction: column; min-height: 100vh;">
    <div style="width: 100%;">
        <header>
              @include('partials.header')
              <div class="hamburger-menu" onclick="toggleSidebar(this)">
         <i class="fas fa-bars"></i>
      </div>
        </header>
<div class="container">
<!-- Add Admin Form -->
    <div class="card">
        <h2>Add New Administrator</h2>
        <form onsubmit="event.preventDefault();">
            <div class="form-grid">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" placeholder="Enter full name" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" placeholder="Enter email" required>
                </div>
                <div class="form-group">
                    <label>Role</label>
                    <select required>
                        <option value="" disabled selected>Select Role</option>
                        <option>Principal</option>
                        <option>Teacher</option>
                        <option>MSWD Officer</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" placeholder="Enter password" required>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit">Add Admin</button>
            </div>
        </form>
    </div>

    <!-- Existing Admins Table -->
    <div class="card">
        <h2>Existing Administrators</h2>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email Address</th>
                    <th>Role</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Principal Doe</td>
                    <td>principal@caresprout.com</td>
                    <td>Principal</td>
                    <td><a href="#">Edit</a> | <a href="#" class="delete">Delete</a></td>
                </tr>
                <tr>
                    <td>Teacher Doe</td>
                    <td>teacherAdmin@caresprout.com</td>
                    <td>Teacher</td>
                    <td><a href="#">Edit</a> | <a href="#" class="delete">Delete</a></td>
                </tr>
                <tr>
                    <td>MSWD Officer Doe</td>
                    <td>mswdAdmin@caresprout.com</td>
                    <td>MSWD Officer</td>
                    <td><a href="#">Edit</a> | <a href="#" class="delete">Delete</a></td>
                </tr>
                <!-- Duplicate more sample rows as needed -->
            </tbody>
        </table>
    </div>

</div>
</body>
</html>
