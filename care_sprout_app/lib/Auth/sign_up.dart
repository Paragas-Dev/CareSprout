import 'dart:io';

import 'package:care_sprout/Auth/login.dart';
import 'package:care_sprout/Auth/second_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rive/rive.dart' as rive;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Rive assets for the buttons
  rive.SMITrigger? buttonClick, backClick;
  rive.StateMachineController? buttonController, backController;
  rive.Artboard? artboard, backArtboard;

  // Controllers for the text fields
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final genderController = TextEditingController();
  final birthYearController = TextEditingController();
  final TextEditingController lrnController = TextEditingController();
  final TextEditingController homeAddressController = TextEditingController();
  final TextEditingController otherDisabilityController =
      TextEditingController();

  String? selectedDisability;
  String? selectedGender;
  File? _assessmentFile;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  // validation state
  bool _lastNameError = false;
  final bool _firstNameError = false;
  final bool _middleNameError = false;
  final bool _birthYearError = false;
  final bool _disabilityError = false;

  @override
  void initState() {
    _loadRiveAssets();
    super.initState();
  }

  Future<void> _loadRiveAssets() async {
    final nextBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/nextbtn.riv',
      stateMachineName: 'Next Button',
      triggerName: 'Next Click',
    );
    final backBtn = await loadRiveButton(
      assetPath: 'assets/Rive_Files/backarrow.riv',
      stateMachineName: 'backArrow',
      triggerName: 'btn Click',
    );

    setState(() {
      artboard = nextBtn.artboard;
      buttonController = nextBtn.controller;
      buttonClick = nextBtn.trigger;

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      });
    }
  }

  void _onNextTap() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (buttonClick != null) {
      buttonClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          String disabilityToPass = selectedDisability == 'Others'
              ? otherDisabilityController.text.trim()
              : (selectedDisability ?? 'Please specify');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecondSignUp(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      middleName: middleNameController.text,
                      gender: selectedGender ?? '',
                      birthYear: birthYearController.text,
                      disability: disabilityToPass,
                      homeAddress: homeAddressController.text,
                      lrn: lrnController.text,
                    )),
          );
        }
      });
    }
  }

  Future<void> _pickAssessmentImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _assessmentFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthYearController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabilities = [
      'Visual Impairment',
      'Hearing Impairment',
      'Physical Disability',
      'Speech Disorder',
      'Interpersonal Behavioral Disorder',
      'Others'
    ];
    return SafeArea(
        child: Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (backArtboard != null)
                          GestureDetector(
                            onTap: _onTap,
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: rive.Rive(
                                artboard: backArtboard!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Image.asset(
                      'assets/name.png',
                      width: 180,
                      height: 180,
                    ),
                    const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontFamily: 'Luckiest Guy',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF488A01),
                      ),
                    ),
                    CustomTextFieldContainer(
                      labelText: 'LAST NAME',
                      controller: lastNameController,
                      error: _lastNameError,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (_lastNameError && value.trim().isNotEmpty) {
                          setState(() {
                            _lastNameError = false;
                          });
                        }
                      },
                    ),
                    CustomTextFieldContainer(
                      labelText: 'FIRST NAME',
                      controller: firstNameController,
                      error: _firstNameError,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextFieldContainer(
                      labelText: 'MIDDLE NAME',
                      controller: middleNameController,
                      error: _middleNameError,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Middle name is required';
                        }
                        return null;
                      },
                    ),
                    GestureDetector(
                      onTap: _pickBirthDate,
                      child: AbsorbPointer(
                        child: CustomTextFieldContainer(
                          labelText: 'BIRTH YEAR',
                          controller: birthYearController,
                          error: _birthYearError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Birth year is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    CustomTextFieldContainer(
                      labelText: 'HOME ADDRESS',
                      controller: homeAddressController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Home address is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextFieldContainer(
                      labelText: 'LEARNER REFERENCE NUMBER (LRN)',
                      controller: lrnController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'LRN is required';
                        }
                        if (value.length != 12) {
                          return 'LRN must be 12 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'LRN must be numeric';
                        }
                        return null;
                      },
                    ),
                    CustomDropdownContainer(
                      labelText: 'Type of Learner',
                      items: disabilities,
                      selectedItem: selectedDisability,
                      onChanged: (value) {
                        setState(() {
                          selectedDisability = value;
                        });
                      },
                      error: _disabilityError,
                    ),
                    if (selectedDisability == 'Others')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomTextFieldContainer(
                          labelText: 'Please specify',
                          controller: otherDisabilityController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please specify the disability';
                            }
                            return null;
                          },
                        ),
                      ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GENDER',
                        style: TextStyle(
                          fontFamily: 'Luckiest Guy',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF488A01),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'Male',
                              style: TextStyle(
                                fontFamily: 'Luckiest Guy',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF488A01),
                                fontSize: 18,
                              ),
                            ),
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'Female',
                              style: TextStyle(
                                fontFamily: 'Luckiest Guy',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF488A01),
                                fontSize: 18,
                              ),
                            ),
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assessment (Optional)',
                            style: TextStyle(
                              fontFamily: 'Luckiest Guy',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF488A01),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickAssessmentImage,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3D981),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_assessmentFile != null)
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.file(_assessmentFile!,
                                      fit: BoxFit.cover),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: artboard == null
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : GestureDetector(
                                    onTap: _onNextTap,
                                    child: rive.Rive(
                                      artboard: artboard!,
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
            ),
          ),
        ),
      ),
    ));
  }
}

class CustomTextFieldContainer extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final bool error;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const CustomTextFieldContainer({
    super.key,
    required this.labelText,
    this.controller,
    this.error = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: const TextStyle(
              fontFamily: 'Luckiest Guy',
              fontWeight: FontWeight.bold,
              color: Color(0xFF488A01),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB3D981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CustomDropdownContainer extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final Widget? child;
  final bool error;

  const CustomDropdownContainer({
    super.key,
    required this.labelText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.child,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: const TextStyle(
              fontFamily: 'Luckiest Guy',
              fontWeight: FontWeight.bold,
              color: Color(0xFF488A01),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (value) {
            if (selectedItem == null || selectedItem!.isEmpty) {
              return 'Please select a type of learner';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFB3D981), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: state.errorText,
                  ),
                  isEmpty: selectedItem == null || selectedItem!.isEmpty,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedItem,
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        onChanged(value);
                        state.didChange(value);
                      },
                      isExpanded: true,
                    ),
                  ),
                ),
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child!,
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
