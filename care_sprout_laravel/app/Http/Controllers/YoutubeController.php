<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use GuzzleHttp\Client;
use Illuminate\Http\Request;

class YoutubeController extends Controller {

    public function getVideoTitle(Request $request) {
        $videoId = $request->query('videoId');
        $apiKey = env('YOUTUBE_API_KEY');

        $client = new Client();
        $response = $client->get("https://www.googleapis.com/youtube/v3/videos", [
            'query' => [
                'id' => $videoId,
                'key' => $apiKey,
                'part' => 'snippet',
                'fields' => 'items/snippet/title'
            ]
        ]);
        return response($response->getBody(), $response->getStatusCode());
    }
}
