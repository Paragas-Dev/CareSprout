// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names, unused_element_parameter

import 'dart:io';

import 'package:care_sprout/Components/pdf_viewer_screen.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/downloads_database.dart';
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Helper/lesson_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart' as rive;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final Post post;

  const LessonScreen({super.key, required this.post, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final TextEditingController _commentController = TextEditingController();
  var backBtn = 'assets/Rive_Files/backarrow.riv';

  rive.SMITrigger? buttonClick;
  rive.StateMachineController? buttonController;
  rive.Artboard? artboard;

  late Post _currentPost;
  late String _lessonId;

  @override
  void initState() {
    rootBundle.load(backBtn).then((value) async {
      await rive.RiveFile.initialize();
      final file = rive.RiveFile.import(value);
      final back = file.mainArtboard;
      buttonController =
          rive.StateMachineController.fromArtboard(back, 'backArrow');
      if (buttonController != null) {
        back.addController(buttonController!);
        buttonController!.inputs.forEach((element) {
          if (element.name == "btn Click") {
            buttonClick = element as rive.SMITrigger;
          }
        });
      }
      setState(() {
        artboard = back;
      });
    });
    super.initState();
    _lessonId = widget.lessonId;
    _currentPost = widget.post;
    AudioService().pauseBgMusic();
  }

  void _onTap() {
    if (buttonClick != null) {
      AudioService().playClickSound();
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // attachment wigdet
  Widget _buildAttachmentWidget(Attachment attachment) {
    String fileType =
        attachment.format?.toLowerCase() ?? attachment.type.toLowerCase();

    switch (fileType) {
      case 'pdf':
        return _AttachmentCard(
          icon: Icons.picture_as_pdf,
          label: attachment.name,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                    fileName: attachment.name, filePath: attachment.url),
              ),
            );
          },
          attachment: attachment,
        );
      case 'image':
        return GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(attachment.url))) {
              await launchUrl(Uri.parse(attachment.url));
            } else {
              debugPrint('Could not launch ${attachment.url}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                attachment.url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, StackTrace) {
                  return const Icon(Icons.broken_image,
                      size: 60, color: Colors.grey);
                },
              ),
            ),
          ),
        );
      case 'video':
        return _AttachmentCard(
          icon: Icons.play_circle_fill,
          label: attachment.name,
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(attachment.url))) {
              await launchUrl(Uri.parse(attachment.url));
            } else {
              debugPrint('Could not launch ${attachment.url}');
            }
          },
          attachment: attachment,
        );
      case 'youtube':
        String? youtubeId = YoutubePlayer.convertUrlToId(attachment.url);
        if (youtubeId != null) {
          return _AttachmentCard(
            iconWidget: Image.network(
              height: 45,
              YoutubePlayer.getThumbnail(
                  videoId: youtubeId, quality: ThumbnailQuality.defaultQuality),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 40.0,
                );
              },
            ),
            label: attachment.name,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: YoutubeVideoPlayer(videoUrl: attachment.url),
                  );
                },
              );
            },
            attachment: attachment,
          );
        }
        return _AttachmentCard(
          icon: Icons.play_circle_fill,
          label: attachment.name,
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(attachment.url))) {
              await launchUrl(Uri.parse(attachment.url));
            } else {
              debugPrint('Could not launch ${attachment.url}');
            }
          },
          attachment: attachment,
        );
      case 'link':
        return _AttachmentCard(
          icon: Icons.link,
          label: attachment.name,
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(attachment.url))) {
              await launchUrl(Uri.parse(attachment.url));
            } else {
              debugPrint('Could not launch ${attachment.url}');
            }
          },
          attachment: attachment,
        );
      default:
        return _AttachmentCard(
          icon: Icons.insert_drive_file,
          label: attachment.name,
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(attachment.url))) {
              await launchUrl(Uri.parse(attachment.url));
            } else {
              debugPrint('Could not launch ${attachment.url}');
            }
          },
          attachment: attachment,
        );
    }
  }

  void _sendComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user signed in');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final parentName = userDoc.data()?['parentName'] ?? 'Unknown';

      // Save comment to Firestore
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(_lessonId)
          .collection('posts')
          .doc(_currentPost.id)
          .collection('class_comments')
          .add({
        'comment': commentText,
        'author': parentName,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      setState(() {
        _commentController.clear();
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("Failed to send comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send comment")),
      );
    }
  }

  @override
  void dispose() {
    AudioService().resumeBgMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFAADDE0),
                Color(0xFFCBE9DF),
                Color(0xFFEBF3DE),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (artboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: rive.Rive(
                            artboard: artboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  thickness: 3,
                  color: Color(0xFFBF8C33),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSize,
                  builder: (context, fontSize, child) {
                    return Text(
                      _currentPost.text,
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontFamily: 'Aleo',
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Attachments Section
                if (_currentPost.attachments.isNotEmpty) ...[
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSize,
                    builder: (context, fontSize, child) {
                      return Text(
                        'Attachments',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'Aleo',
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Render attachments dynamically
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentPost.attachments.length,
                    itemBuilder: (context, index) {
                      final attachment = _currentPost.attachments[index];
                      return _buildAttachmentWidget(attachment);
                    },
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(
                  height: 10,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSize,
                  builder: (context, fontSize, child) {
                    return Text(
                      'Class comments',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'Aleo',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  },
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('lessons')
                      .doc(_lessonId)
                      .collection('posts')
                      .doc(_currentPost.id)
                      .collection('class_comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No class comments yet.");
                    }

                    final comments = snapshot.data!.docs;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 10),
                      itemBuilder: (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;
                        final author = comment['author'] ?? 'Anonymous';
                        final content = comment['comment'] ?? '';
                        final timestamp = comment['timestamp'] as Timestamp?;
                        final commentUid = comment['uid'];

                        final currentUser = FirebaseAuth.instance.currentUser;
                        final isAuthor = comment['uid'] == currentUser?.uid;

                        return GestureDetector(
                          onTap: () {
                            if (isAuthor) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.delete,
                                              color: Colors.red),
                                          title: const Text('Delete'),
                                          onTap: () async {
                                            Navigator.pop(
                                                context); // Close modal
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('lessons')
                                                  .doc(_lessonId)
                                                  .collection('posts')
                                                  .doc(_currentPost.id)
                                                  .collection('class_comments')
                                                  .doc(comments[index].id)
                                                  .delete();
                                            } catch (e) {
                                              debugPrint(
                                                  'Failed to delete comment: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Failed to delete comment')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFBF8C33),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34732F),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(content),
                                const SizedBox(height: 4),
                                Text(
                                  timestamp != null
                                      ? _formatDate(timestamp)
                                      : '',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFBF8C33)),
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Class comment",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(color: Color(0xFFBF8C33)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF8C33),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final String? format;
  final Attachment attachment;

  const _AttachmentCard({
    this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
    this.format,
    required this.attachment,
  });

  Future<void> _downloadAndSaveFile(BuildContext context) async {
    try {
      final existingDownload =
          await DownloadsDatabase.instance.getDownloadByUrl(attachment.url);
      if (existingDownload != null) {
        _showSnackBar(context, 'File already downloaded!');
        return;
      }

      _showSnackBar(context, 'Downloading ${attachment.name}...');
      final response = await http.get(Uri.parse(attachment.url));
      final directory = await getApplicationDocumentsDirectory();
      final localPath =
          '${directory.path}/${attachment.name.replaceAll(RegExp(r'[^\w\s\.-]'), '')}';
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);

      await DownloadsDatabase.instance.insertDownload({
        'name': attachment.name,
        'url': attachment.url,
        'localPath': localPath,
      });

      _showSnackBar(context, 'Download successfully!');
    } catch (e) {
      _showSnackBar(context, 'Download failed: $e');
      debugPrint('Download failed: $e');
    }
  }

  void _openFile(BuildContext context, String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        if (attachment.type == 'pdf') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                  filePath: localPath, fileName: attachment.name),
            ),
          );
        } else {
          // You would need to handle other file types here, e.g., with an external viewer
          _showSnackBar(context, 'File opened from local storage.');
        }
      } else {
        _showSnackBar(context, 'Downloaded file not found.');
      }
    } catch (e) {
      _showSnackBar(context, 'Could not open file: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: iconWidget ??
                        Icon(icon, color: const Color(0xFFBF8C33), size: 40),
                  ),
                ],
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSize,
                  builder: (context, fontSize, child) {
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        fontFamily: 'Aleo',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              PopupMenuButton<String>(
                onSelected: (String result) async {
                  if (result == 'Download') {
                    await _downloadAndSaveFile(context);
                  } else if (result == 'Open') {
                    final download = await DownloadsDatabase.instance
                        .getDownloadByUrl(attachment.url);
                    if (download != null) {
                      _openFile(context, download['localPath']);
                    } else {
                      _showSnackBar(context, 'File not downloaded yet.');
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new, size: 20),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFFBF8C33),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const YoutubeVideoPlayer({super.key, required this.videoUrl});

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      onReady: () {
        debugPrint('Player is ready.');
      },
    );
  }
}
