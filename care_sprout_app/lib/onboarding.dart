import 'package:care_sprout/Auth/login.dart';
import 'package:care_sprout/Helper/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  var riveUrl = 'assets/Rive_Files/start_btn.riv';
  rive.SMITrigger? buttonClick, fly;
  rive.StateMachineController? buttonController;
  rive.StateMachineController? planeController,
      cloudController,
      cloudController2;
  rive.Artboard? artboard;
  rive.Artboard? planeArtboard, cloudArtboard, cloudArtboard2;

  @override
  void initState() {
    rootBundle.load(riveUrl).then((value) async {
      await rive.RiveFile.initialize();
      final file = rive.RiveFile.import(value);
      final art = file.mainArtboard;
      buttonController =
          rive.StateMachineController.fromArtboard(art, 'Button Start');
      if (buttonController != null) {
        art.addController(buttonController!);
        buttonController!.inputs.forEach((element) {
          if (element.name == "Button_Click") {
            buttonClick = element as rive.SMITrigger;
          }
        });
      }
      setState(() {
        artboard = art;
      });
    });

    rootBundle.load('assets/Rive_Files/airplane.riv').then((value) async {
      await rive.RiveFile.initialize();
      final planeFile = rive.RiveFile.import(value);
      final plane = planeFile.mainArtboard;
      planeController =
          rive.StateMachineController.fromArtboard(plane, 'State Machine 1');
      if (planeController != null) {
        plane.addController(planeController!);
      }
      setState(() {
        planeArtboard = plane;
      });
    });

    rootBundle
        .load('assets/Rive_Files/animated_clouds.riv')
        .then((value) async {
      await rive.RiveFile.initialize();
      final cloudsFile2 = rive.RiveFile.import(value);
      final clouds2 = cloudsFile2.mainArtboard;
      cloudController2 =
          rive.StateMachineController.fromArtboard(clouds2, 'Clouds');
      if (cloudController2 != null) {
        clouds2.addController(cloudController2!);
      }
      setState(() {
        cloudArtboard2 = clouds2;
      });
    });

    rootBundle
        .load('assets/Rive_Files/animated_clouds.riv')
        .then((value) async {
      await rive.RiveFile.initialize();
      final cloudsFile = rive.RiveFile.import(value);
      final clouds = cloudsFile.mainArtboard;
      cloudController =
          rive.StateMachineController.fromArtboard(clouds, 'Clouds');
      if (cloudController != null) {
        clouds.addController(cloudController!);
      }
      setState(() {
        cloudArtboard = clouds;
      });
    });
    super.initState();
  }

  void btnClick() {
    if (buttonClick != null) {
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (mounted) {
          await AuthGate.setOnboardComplete();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          if (cloudArtboard2 != null)
            Positioned(
              right: 0,
              child: SizedBox(
                width: 500,
                height: 500,
                child: rive.Rive(
                  artboard: cloudArtboard2!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (cloudArtboard != null)
            Positioned(
              child: SizedBox(
                width: 700,
                height: 700,
                child: rive.Rive(
                  artboard: cloudArtboard!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (planeArtboard != null)
            Positioned(
              top: 50,
              right: 40,
              child: SizedBox(
                width: 250,
                height: 250,
                child: rive.Rive(
                  artboard: planeArtboard!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Positioned(
            top: 200,
            left: 120,
            child: Image.asset(
              'assets/name.png',
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bg_files/back_mountain.png',
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bg_files/front.png',
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 90,
            left: 0,
            right: 50,
            child: Image.asset(
              'assets/bg_files/school.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          if (artboard != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: -50.0,
              child: GestureDetector(
                onTap: btnClick,
                child: SizedBox(
                  width: 100,
                  height: 300,
                  child: rive.Rive(
                    artboard: artboard!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          if (artboard == null)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
