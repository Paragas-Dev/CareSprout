<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;
use Kreait\Firebase\Factory;

class StoreUserRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (Auth::check()) {

            $user = Auth::user();
            
            $firebase = (new Factory)->withServiceAccount(config('firebase.credentials_file'));
            $firestore = $firebase->createFirestore();
            $db = $firestore->database();

            $adminDoc = $db->collection('admin')->document($user->uid)->snapshot();
            if ($adminDoc->exists()) {
                $role = $adminDoc->get('role');
                session(['role' => $role]);
            } else {
                session(['role' => null]);
            }
        }

        return $next($request);
    }
}
