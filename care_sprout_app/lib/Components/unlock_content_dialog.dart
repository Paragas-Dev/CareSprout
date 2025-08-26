import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class UnlockContentDialog extends StatefulWidget {
  const UnlockContentDialog({super.key});

  @override
  State<UnlockContentDialog> createState() => _UnlockContentDialogState();
}

class _UnlockContentDialogState extends State<UnlockContentDialog> {
  rive.SMITrigger? backClick, unlockClick;
  rive.StateMachineController? backController, unlockController;
  rive.Artboard? backArtboard, unlockArtboard;

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

    final unlockBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/unlock_btn.riv',
      stateMachineName: 'Unlock Btn',
      triggerName: 'Unlock Click',
    );

    setState(() {
      backArtboard = backBtn.artboard;
      backController = backBtn.controller;
      backClick = backBtn.trigger;

      unlockArtboard = unlockBtn.artboard;
      unlockController = unlockBtn.controller;
      unlockClick = unlockBtn.trigger;
    });
  }

  @override
  void dispose() {
    unlockController?.dispose();
    super.dispose();
  }

  void _onTap() {
    if (unlockClick != null) {
      AudioService().playClickSound();
      unlockClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFADDEE0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'To continue, ask\nthe grown up for help.',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBF8C33),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (unlockArtboard != null)
                        GestureDetector(
                          onTap: _onTap,
                          child: SizedBox(
                            width: 40,
                            height: 60,
                            child: rive.Rive(
                              artboard: unlockArtboard!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}
