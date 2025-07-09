<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MSWD Officer Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
    <link rel="stylesheet" href="{{ asset('css/sidebar.css') }}">
    <link rel="stylesheet" href="{{ asset('css/mswd-dashboard.css') }}">
</head>
<body style="display: flex; min-height: 100vh;">
    @include('partials.mswd-sidebar')
    <div class="main-content">
        @yield('content')
    </div>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
</body>
</html> 