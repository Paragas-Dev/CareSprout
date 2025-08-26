import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String videoId;
  final String videoTitle;
  final String channelName;
  final String videoDuration;

  const VideoCard({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.channelName,
    required this.videoDuration,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}