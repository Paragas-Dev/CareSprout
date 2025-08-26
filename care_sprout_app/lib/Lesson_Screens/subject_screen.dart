// ignore_for_file: deprecated_member_use
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/lesson_service.dart';
import 'package:care_sprout/Lesson_Screens/lesson_home.dart';
import 'package:care_sprout/Lesson_Screens/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectScreen extends StatefulWidget {
  final String? lessonId;

  const SubjectScreen({super.key, this.lessonId});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  var backBtn = 'assets/Rive_Files/backarrow.riv';

  rive.SMITrigger? buttonClick;
  rive.StateMachineController? buttonController;
  rive.Artboard? artboard;
  final LessonService _lessonService = LessonService();
  Lesson? currentLesson;

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

    // Load lesson data if lessonId is provided
    if (widget.lessonId != null) {
      _loadLesson();
    }

    super.initState();
  }

  Future<void> _loadLesson() async {
    if (widget.lessonId != null) {
      final lesson = await _lessonService.getLessonById(widget.lessonId!);
      if (mounted) {
        setState(() {
          currentLesson = lesson;
        });
      }
    }
  }

  void _onTap() {
    if (buttonClick != null) {
      AudioService().playClickSound();
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LessonHome()),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
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
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
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
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFB3D981),
                                  Color(0xFFBF8C33),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentLesson?.name ?? 'Lesson Title',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontFamily: 'Luckiest Guy',
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF34732F),
                                        offset: Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(
                      thickness: 3,
                      color: Color(0xFFBF8C33),
                    ),

                    // Posts Section
                    widget.lessonId != null
                        ? StreamBuilder<List<Post>>(
                            stream:
                                _lessonService.getPostsStream(widget.lessonId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFBF8C33),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error loading posts: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              List<Post> posts = snapshot.data ?? [];

                              if (posts.isEmpty) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.announcement_outlined,
                                        size: 64,
                                        color: Color(0xFFBF8C33),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No Posts yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFBF8C33),
                                          fontFamily: 'Aleo',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return PostCard(
                                      post: post, lessonId: widget.lessonId);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'No lesson selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final String? lessonId;

  const PostCard({super.key, required this.post, required this.lessonId});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonScreen(
                post: widget.post, lessonId: widget.lessonId ?? ''),
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/LessonCard.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFBF8C33),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0xFF34732F),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(widget.post.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Text(
                  widget.post.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFF34732F),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
