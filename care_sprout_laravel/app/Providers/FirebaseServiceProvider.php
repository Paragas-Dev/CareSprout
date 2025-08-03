<?php

namespace App\Providers;

use App\Http\Controllers\PageController;
use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Illuminate\Support\Facades\Auth;
use Kreait\Firebase\ServiceAccount;
use Google\Cloud\Firestore\FirestoreClient;
use Illuminate\Support\Facades\Route;
use App\Http\Middleware\StoreUserRole;

class FirebaseServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton('firebase', function ($app) {
            $credentialsPath = storage_path('app/firebase/firebase-credentials.json');

            if (!file_exists($credentialsPath)) {
                throw new \Exception("Firebase credentials file not found: $credentialsPath");
            }

            $projectId = config('app.FIREBASE_PROJECT_ID');
            if (!$projectId) {
                throw new \Exception("FIREBASE_PROJECT_ID environment variable is not set");
            }

            return (new Factory)
                ->withServiceAccount($credentialsPath)
                ->withProjectId($projectId);
        });

        $this->app->singleton('firebase.auth', function ($app) {
            return $app['firebase']->createAuth();
        });

        $this->app->singleton('firebase.database', function ($app) {
            return $app['firebase']->getDatabase();
        });

        $this->app->singleton(FirestoreClient::class, function ($app) {
            $credentialsPath = storage_path('app/firebase/firebase-credentials.json');

            if (!file_exists($credentialsPath)) {
                throw new \Exception("Firebase credentials file not found: $credentialsPath");
            }

            $projectId = config('app.FIREBASE_PROJECT_ID');
            if (!$projectId) {
                throw new \Exception("FIREBASE_PROJECT_ID environment variable is not set");
            }

            return new FirestoreClient([
                'projectId' => $projectId,
                'keyFilePath' => $credentialsPath,
                'transport' => 'rest',
                // Add timeout configuration
                'httpHandler' => function ($request, $options = []) {
                    $options['timeout'] = 30;
                    $options['connect_timeout'] = 10;

                    $client = new \GuzzleHttp\Client();
                    return $client->send($request, $options);
                },
            ]);
        });

        $this->app->singleton('firebase.firestore', function ($app) {
            return $app->make(FirestoreClient::class);
        });
    }

    public function getCurrentUserRole()
    {
        $user = Auth::user();
        if (!$user) return null;

        $firestore = app('firebase.firestore');
        $snapshot = $firestore->collection('admin')->document($user->uid)->snapshot();

        return $snapshot->exists() ? $snapshot->data()['role'] : null;
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        Route::middleware([StoreUserRole::class])->group(function () {
            Route::get('/settings', [PageController::class, 'settings'])->name('settings');
            // Add other routes that require the middleware
        });
    }
}
