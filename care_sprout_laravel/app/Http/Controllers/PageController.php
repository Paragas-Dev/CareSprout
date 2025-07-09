<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PageController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function messages()
    {
        return view('communication.messages');
    }

    public function approval()
    {
        // Return empty users array since we're removing Firestore integration
        return view('management.approval');
    }
    

    public function leader()
    {
        return view('management.leader');
    }
    
    public function reports()
    {
        return view('management.reports');
    }

    public function dashboard()
    {
        return view('dashboard.home');
    }

    public function principalDashboard()
    {
        return view('dashboard.principal');
    }

    public function teacherDashboard()
    {
        return view('dashboard.home');
    }

    public function mswdDashboard()
    {
        return view('dashboard.mswd');
    }
}

