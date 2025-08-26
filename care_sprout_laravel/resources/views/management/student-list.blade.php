 <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/header.css') }}">
    <link rel="stylesheet" href="{{ asset('css/student-list.css') }}">
    <title>Student</title>
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

        </div>
    </div>
</body>
</html>
