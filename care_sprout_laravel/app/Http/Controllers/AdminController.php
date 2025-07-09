<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function create()
    {
        // Only allow principal
        if (auth()->user()->role !== 'principal') {
            abort(403);
        }
        return view('admin.add');
    }
}
