<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\YoutubeController;

Route::get('/youtube-title', [YoutubeController::class, 'getVideoTitle']);
