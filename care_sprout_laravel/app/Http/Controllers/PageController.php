<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PageController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    //Principal Views
    public function principalDashboard()
    {
        return view('dashboard.principal');
    }

    public function announcements()
    {
        return view('principal_admin.announcements');
    }

    public function administrator()
    {
        return view('principal_admin.administrator');
    }
    public function students()
    {
        return view('principal_admin.students');
    }


    //Teacher Views

    public function dashboard()
    {
        return view('dashboard.home');
    }

    public function messages()
    {
        return view('communication.messages');
    }

    public function approval()
    {
        return view('management.approval');
    }


    public function leader()
    {
        return view('management.leader');
    }

    public function announcement()
    {
        return view('management.announcement');
    }

    public function reports()
    {
        return view('management.reports');
    }

    public function lessonArchives()
    {
        return view('lessons.lesson-archives');
    }

    //MSWD Views

    public function mswdDashboard()
    {
        return view('dashboard.mswd');
    }


    // Shared Settings
    public function settings(Request $request)
    {
        $role = session('role', 'guest');

        return view('management.settings', compact('role'));
    }
}

