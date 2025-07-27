<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Announcement Board</title>
    <link rel="stylesheet" href="{{ asset('css/ano.css') }}">
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

<div class="card announcement-form">
    <h2>Post New Announcement</h2>
    <form>
        <input type="text" name="title" placeholder="Enter title..." required>
        <textarea name="content" placeholder="Write your announcement here..." rows="5" required></textarea>
        <input type="text" name="posted_by" placeholder="Your name..." required>
        <button type="submit" onclick="event.preventDefault();">+ Post Announcement</button>
    </form>
</div>


                <div class="card announcement-list">
                    <h2>Recent Announcements</h2>
                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Posted by</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Lumipad ang aming team</td>
                                    <td>Principal Doe</td>
                                    <td>2025-10-07</td>
                                    <td><a href="#">View</a> | <a href="#" class="delete">Delete</a></td>
                                </tr>
                                <tr>
                                    <td>S-line Unlimited</td>
                                    <td>Teacher Doe</td>
                                    <td>2028-10-09</td>
                                    <td><a href="#">View</a> | <a href="#" class="delete">Delete</a></td>
                                </tr>
                                <tr>
                                    <td>Week of Down</td>
                                    <td>Teacher Doe</td>
                                    <td>2025-07-18</td>
                                    <td><a href="#">View</a> | <a href="#" class="delete">Delete</a></td>
                                </tr>
                                <tr>
                                    <td>I shall return</td>
                                    <td>Teacher Doe</td>
                                    <td>2025-07-18</td>
                                    <td><a href="#">View</a> | <a href="#" class="delete">Delete</a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>
</body>
</html>
