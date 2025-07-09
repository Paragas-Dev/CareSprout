<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\ServiceAccount;
use Google\Cloud\Firestore\FirestoreClient;

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
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
} 