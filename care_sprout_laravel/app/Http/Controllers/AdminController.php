<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    public function create()
    {
        // Only allow principal
        if (Auth::user()->role !== 'principal') {
            abort(403);
        }
        return view('admin.add');
    }
}
