<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PageController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\SettingsController;
use App\Http\Middleware\StoreUserRole;

// Main route
Route::get('/', function () {
    return view('auth.login');
});

// login
Route::get('/login', [PageController::class, 'showLogin'])->name('login');

// --- Protected Routes for Principals ---

    // Principal Dashboard
    Route::get('/principal', [PageController::class, 'principalDashboard'])->name('principal.dashboard');

    // students management
    Route::get('/students', [PageController::class, 'students'])->name('students');

    // announcements
    Route::get('/announcements', [PageController::class, 'announcements'])->name('announcements');

    // administrator
    Route::get('/administrator', [PageController::class, 'administrator'])->name('administrator');
    Route::delete('/admin/delete/{uid}', [AdminController::class, 'deleteAdmin']);

    // Principal Settings
    Route::get('/principal/settings', function () {
        return redirect()->route('settings');
    });





// --- Protected Routes for Teachers and other roles ---

    //teacher Dashboard
    Route::get('/home', [PageController::class, 'dashboard'])->name('home');

    //Messages
    Route::get('/messages', [PageController::class, 'messages'])->name('messages');

    //Approval
    Route::get('/approval', [PageController::class, 'approval'])->name('approval');

    //Leaderboards
    Route::get('/leader', [PageController::class, 'leader'])->name('leader');

    //Announcements
    Route::get('/announcement', [PageController::class, 'announcement'])->name('announcement');

    //Reports
    Route::get('/reports', [PageController::class, 'reports'])->name('reports');

    //Lesson Home
    Route::get('/lessons', function () {
        return view('lessons.lesson-home');
    })->name('lessons.home');

    //Lesson Stream
    Route::get('/lesson-stream/{lessonId}', function ($lessonId) {
        return view('lessons.lesson-stream', ['lessonId' => $lessonId]);
    })->name('lesson-stream');

    //Lesson Archives
    Route::get('/lesson-archives', [PageController::class, 'lessonArchives'])->name('lessons.archived');

    // Teacher settings
    Route::get('/teacher/settings', function () {
        return redirect()->route('settings');
    });





// --- Protected Routes for MSWD Officers ---
    Route::get('/mswd', [PageController::class, 'mswdDashboard'])->name('mswd.dashboard');


    // Shared Settings
    // Route::get('/settings', [PageController::class, 'settings'])->name('settings');
    Route::middleware([StoreUserRole::class])->group(function () {
        Route::get('/settings', [PageController::class, 'settings'])->name('settings');
    });

// --- Authentication Routes ---

Route::post('/set-role', function (\Illuminate\Http\Request $request) {
    session(['role' => $request->role]);
    return response()->json(['status' => 'ok']);
});
Route::post('/logout-session', function () {
    session()->flush();
    return response()->json(['status' => 'ok']);
});
