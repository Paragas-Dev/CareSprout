<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Kreait\Firebase\Auth as FirebaseAuth;
use Kreait\Firebase\Firestore;

class AdminController extends Controller
{
    public function deleteAdmin($uid)
    {
        try {
            // Delete from Firebase Auth
            $auth = app('firebase.auth');
            $auth->deleteUser($uid);

            // Delete from Firestore
            $firestore = app('firebase.firestore');
            $firestore->collection('admin')->document($uid)->delete();

            return response()->json(['message' => 'Admin deleted successfully.'], 200);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
