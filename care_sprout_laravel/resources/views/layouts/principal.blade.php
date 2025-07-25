<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Principal Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
</head>
<body>
    @include('partials.principal-sidebar')
    <div class="main-content">
        @yield('content')
    </div>
    <script src="{{ asset('js/firebase-config.js') }}"></script>
</body>
</html>
