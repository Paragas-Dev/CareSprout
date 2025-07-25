<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CARESPROUT</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
  <link rel="stylesheet" href="{{ asset('css/header.css') }}">
  <link rel="stylesheet" href="{{ asset('css/leaderboard.css') }}">
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
      <div class="leaderboard-container">
        <div class="leaderboard-header" style="justify-content: space-between;">
          <span>LEADERBOARD</span>
        </div>
        <div class="leaderboard-podium">
          <div class="podium-row podium-row-top">
            <div class="podium-student main-student">
              <div class="podium-avatar"><i class="fas fa-user"></i></div>
              <div class="podium-name">Student Name<br><span class="podium-disability">Disability1</span></div>
            </div>
          </div>
          <div class="podium-row podium-row-bottom">
            <div class="podium-student side-student">
              <div class="podium-avatar"><i class="fas fa-user"></i></div>
              <div class="podium-name">Student Name<br><span class="podium-disability">Disability3</span></div>
            </div>
            <div class="podium-student side-student">
              <div class="podium-avatar"><i class="fas fa-user"></i></div>
              <div class="podium-name">Student Name<br><span class="podium-disability">Disability2</span></div>
            </div>
          </div>
          <div class="podium-row" style="margin-top: 30px; justify-content: flex-start;">
            <div style="display: flex; align-items: center; gap: 12px; color: #a16600; font-weight: bold; font-size: 18px;">
              <span style="font-size: 18px;">4</span>
              <span class="podium-avatar" style="width: 38px; height: 38px; font-size: 18px; background: #b7e1e4;"><i class="fas fa-user"></i></span>
              <span style="font-size: 17px;">Student Name</span>
              <span style="font-size: 17px;">Disability2</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    function toggleDropdown(element) {
      element.classList.toggle("active");
    }

    document.addEventListener("click", function(event) {
      const drop = document.querySelector(".drop");
      if (drop && !drop.contains(event.target)) {
        drop.classList.remove("active");
      }
    });

    function goBack() {
      window.history.back();
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
