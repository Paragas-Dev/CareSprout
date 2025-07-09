import 'package:care_sprout/Helper/global_font_size.dart';
import 'package:care_sprout/Lesson_Screens/subject_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  var backBtn = 'assets/Rive_Files/backarrow.riv';

  rive.SMITrigger? buttonClick;
  rive.StateMachineController? buttonController;
  rive.Artboard? artboard;

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
  }

  void _onTap() {
    if (buttonClick != null) {
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubjectScreen()),
          );
        }
      });
    }
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
                // Rive back button (scrolls with content)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (artboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: rive.Rive(
                            artboard: artboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(width: 40.0),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFFB3D981),
                            Color(0xFFBF8C33),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: ValueListenableBuilder<double>(
                        valueListenable: FontSizeController.fontSize,
                        builder: (context, fontSize, child) {
                          return Text(
                            'Lesson Title',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontFamily: 'Aleo',
                              letterSpacing: 1.5,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF34732F),
                                  offset: Offset(2, 2),
                                  blurRadius: 3,
                                ),
                              ],
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        },
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
                Row(
                  children: [
                    Expanded(
                      child: _AttachmentCard(
                        icon: Icons.description,
                        label: "Lesson 1",
                        onMenuSelected: (value) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AttachmentCard(
                        iconWidget: const Icon(Icons.play_circle_fill,
                            color: Colors.red, size: 40),
                        label: "Lesson1.YT",
                        onMenuSelected: (value) {},
                      ),
                    ),
                  ],
                ),
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
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Class comment",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(color: Color(0xFFBF8C33)),
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
                        onPressed: () {},
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
  final void Function(String)? onMenuSelected;

  const _AttachmentCard({
    this.icon,
    this.iconWidget,
    required this.label,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: iconWidget ??
                  Icon(icon, color: const Color(0xFFBF8C33), size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSize,
                    builder: (context, fontSize, child) {
                      return Text(
                        label,
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
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFFBF8C33)),
                  onSelected: onMenuSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Text('Download'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
