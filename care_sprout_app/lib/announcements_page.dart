import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:rive/rive.dart' as rive;

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
  }

  Future<void> _loadRiveAssets() async {
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;
    });
  }

  void _onTap() {
    if (backClick != null) {
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Row(
                        children: [
                          if (backArtboard != null)
                            GestureDetector(
                              onTap: _onTap,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: rive.Rive(
                                  artboard: backArtboard!,
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
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Announcements",
                                    style: TextStyle(
                                      fontSize: 30,
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
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(
                      thickness: 3,
                      color: Color(0xFFBF8C33),
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: StreamBuilder<cf.QuerySnapshot>(
                        stream: cf.FirebaseFirestore.instance
                            .collection('announcements')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No announcements available.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Aleo',
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final title = data['title'] ?? 'Announcement';
                              final content = data['content'] ?? '';
                              final createdAt =
                                  data['createdAt'] as cf.Timestamp?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.announcement,
                                          color: Color(0xFF34732F),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ValueListenableBuilder<double>(
                                            valueListenable:
                                                FontSizeController.fontSize,
                                            builder:
                                                (context, fontSize, child) {
                                              return Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: fontSize * 0.8,
                                                  fontFamily: 'Luckiest Guy',
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF34732F),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      content,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Aleo',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (createdAt != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Posted on: ${_formatDate(createdAt.toDate())}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Aleo',
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
