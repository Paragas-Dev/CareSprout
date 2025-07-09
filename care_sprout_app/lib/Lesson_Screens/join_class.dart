import 'package:flutter/material.dart';

class JoinClass extends StatefulWidget {
  const JoinClass({super.key});

  @override
  State<JoinClass> createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFAADDE0),
                Color(0xFFCBE9DF),
                Color(0xFFEBF3DE),
              ],
              stops: [0.0, 0.2, 1.0],
            ),
            border: Border.all(color: Colors.black26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFCCE6A6),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Color(0xFFB88C33)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Join class",
                        style: TextStyle(
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDFF5C8),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                      },
                      child: const Text(
                        "JOIN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: 'Aleo'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ask your teacher for the class code, then enter it here.",
                      style: TextStyle(fontSize: 15, fontFamily: 'Aleo'),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Class code",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFFB88C33)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFFB88C33)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                              color: Color(0xFFB88C33), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
