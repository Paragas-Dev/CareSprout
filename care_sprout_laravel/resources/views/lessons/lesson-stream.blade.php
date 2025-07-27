<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Letters</title>
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/lesson-stream.css') }}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/announcement-form.css') }}">
    <link rel="stylesheet" href="{{ asset('css/people-stream.css') }}">

</head>
<body data-auth-user-name="{{ Auth::check() ? Auth::user()->name : 'Default Admin Name' }}">
    @include('partials.sidebar')
    <div class="main-container">
        <header>
            @include('partials.header')
        </header>
        <div class="hamburger-menu" onclick="toggleSidebar(this)">
          <i class="fas fa-bars"></i>
      </div>
        <div class="lessons-content">
            <div class="lesson-title-row">
              <h1><span id="lesson-title"></span></h1>
              <div class="lesson-info-container">
                <i class="fas fa-info-circle" id="lesson-info-icon" title="About this lesson"></i>
                <div class="lesson-info-popup" id="lesson-info-popup">
                        <span id="join-code-display"></span> <i class="far fa-copy copy-icon" title="Copy to clipboard"></i>
                </div>
            </div>
            </div>
            <div class="lessons-tabs">
                <span class="tab active" data-tab="stream">Stream</span>
                <span class="tab" data-tab="progress">Progress</span>
                <span class="tab" data-tab="people">People</span>
            </div>
            <div id="tab-content-stream">
                <div id="announcement-card" class="announcement-card">
                    <span>Announcement</span>
                    <i class="fas fa-plus"></i>
                </div>
                <div id="announcement-form-container" class="announcement-form-wrapper">
                    @include('partials.announcement-form')
                </div>
                <div id="posts-container"></div>
            </div>
            <div id="tab-content-progress" style="display:none;">
                <div style="padding: 40px; text-align: center; color: #aaa; font-size: 1.2em;">Progress under construction</div>
            </div>
            <div id="tab-content-people" style="display:none;">
                @include('lessons.people')
            </div>
        </div>
    </div>

    <div id="announcement-modal-backdrop" class="modal-backdrop"></div>

    <span class="copy-feedback" id="copy-feedback">Copied!</span>

    <!-- Centralized Firebase Configuration -->
    <script src="{{ asset('js/firebase-config.js') }}"></script>
    <script src="https://cdn.ckeditor.com/4.25.1-lts/standard/ckeditor.js"></script>

    <script src="https://apis.google.com/js/api.js"></script>

    <script src="https://upload-widget.cloudinary.com/latest/global/all.js" type="text/javascript"></script>

    <script src="{{ asset('js/lesson-stream-scripts.js') }}"></script>

</body>
</html>
