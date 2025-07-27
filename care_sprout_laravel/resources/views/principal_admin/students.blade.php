<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="{{ asset('css/students.css') }}">
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
        <section class="summary">
            <h2>Student Summary</h2>
            <div class="cards">
                <div class="card blue">
                    <p>Total SPED Students</p>
                    <h1>999</h1>
                    <span class="icon">Icon</span>
                </div>
                <div class="card green">
                    <p>E-learning Engagement</p>
                    <h1>92%</h1>
                    <span class="icon">Icon</span>
                </div>
            </div>
            <div class="filters">
                <input type="text" placeholder="Search Student">
                <select>
                    <option>All</option>
                    <option>ASD</option>
                    <option>ADHD</option>
                </select>
                <button class="apply">Apply Filters</button>
            </div>
        </section>

        <section class="records">
            <h2>Student Records</h2>
            <button class="add">+ Add new Student</button>
            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Disability</th>
                        <th>Guardian's Name</th>
                        <th>Avg. Progress</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    @for($i = 0; $i < 8; $i++)
                    <tr>
                        <td>John Doe</td>
                        <td>ASD</td>
                        <td>Mama Doe</td>
                        <td>85%</td>
                        <td>Excellent <a href="#">View Details</a></td>
                    </tr>
                    @endfor
                </tbody>
            </table>
        </section>
    </div>

</body>
</html>
