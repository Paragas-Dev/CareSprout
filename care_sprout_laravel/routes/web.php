<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PageController;
use App\Http\Controllers\AdminController;

// Main route
Route::get('/', function () {
    return view('auth.login');
});

// login
Route::get('/login', [PageController::class, 'showLogin'])->name('login');

// Dashboard routes based on role
Route::get('/home', [PageController::class, 'dashboard'])->name('home');

Route::get('/principal', [PageController::class, 'principalDashboard'])->name('principal.dashboard');

Route::get('/mswd', [PageController::class, 'mswdDashboard'])->name('mswd.dashboard');

//Messages
Route::get('/messages', [PageController::class, 'messages'])->name('messages');

//Approval
Route::get('/approval', [PageController::class, 'approval'])->name('approval');

//Leaderboards
Route::get('/leader', [PageController::class, 'leader'])->name('leader');

//Reports
Route::get('/reports', [PageController::class, 'reports'])->name('reports');

//Lesson Stream
Route::get('/lesson-stream/{lessonId}', function ($lessonId) {
    return view('lessons.lesson-stream', ['lessonId' => $lessonId]);
})->name('lesson-stream');

// Create Admin
Route::get('/create-admin', function () {
    return view('admin.create-admin');
});

// Admin Add
Route::get('/admin/add', [AdminController::class, 'create'])->name('admin.create');
