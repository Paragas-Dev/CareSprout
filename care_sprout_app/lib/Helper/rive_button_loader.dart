import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class RiveButtonAssets {
  final rive.Artboard? artboard;
  final rive.SMITrigger? trigger;
  final rive.StateMachineController? controller;

  RiveButtonAssets(this.artboard, this.trigger, this.controller);
}

Future<RiveButtonAssets> loadRiveButton({
  required String assetPath,
  required String stateMachineName,
  required String triggerName,
}) async {
  await rive.RiveFile.initialize();
  final data = await rootBundle.load(assetPath);
  final file = rive.RiveFile.import(data);
  final artboard = file.mainArtboard;
  final controller =
      rive.StateMachineController.fromArtboard(artboard, stateMachineName);
  rive.SMITrigger? trigger;
  if (controller != null) {
    artboard.addController(controller);
    for (var input in controller.inputs) {
      if (input.name == triggerName) {
        trigger = input as rive.SMITrigger;
      }
    }
  }
  return RiveButtonAssets(artboard, trigger, controller);
}
