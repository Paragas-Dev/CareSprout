import 'package:flutter/material.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final String title;
  final String content;
  final String? postedOn;

  const AnnouncementDetailsScreen({
    super.key,
    required this.title,
    required this.content,
    this.postedOn
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: const Color(0xFF34732F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Luckiest Guy',
                fontWeight: FontWeight.bold,
                color: Color(0xFF34732F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Aleo',
                color: Colors.black87,
              ),
            ),
            if (postedOn != null) ...[
              const SizedBox(height: 24),
              Text(
                'Posted on: $postedOn',
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Aleo',
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}