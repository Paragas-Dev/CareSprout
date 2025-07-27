<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
    <title>Principal Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/settings.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/principal-sidebar.css') }}">
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
    <div class="card">
      <h2>General Settings</h2>
      <form>
        <label>Your name</label>
        <input type="text" name="name" value="Principal Doe">

        <label>Your Email</label>
        <input type="email" name="email" value="principalAdmin@caresprout.com">

        <button type="submit" class="save-btn">Save Settings</button>
      </form>
    </div>

    <div class="card">
      <h2>Change Password</h2>
      <p>Update your account password for enhanced security.</p>
      <form>
        <label>Current Password</label>
        <input type="password" name="current_password">

        <label>New Password</label>
        <input type="password" name="new_password">

        <label>Confirm New Password</label>
        <input type="password" name="new_password_confirmation">

        <button type="submit" class="change-btn">Change Password</button>
      </form>
    </div>
  </div>
</body>
</html>
