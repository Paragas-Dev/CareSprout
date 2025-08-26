import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentVerification extends StatefulWidget {
  const ParentVerification({super.key});

  @override
  State<ParentVerification> createState() => _ParentVerificationState();
}

class _ParentVerificationState extends State<ParentVerification> {
  String _enteredPin = '';
  String? _errorText;
  String _storedBirthYear = '';

  @override
  void initState() {
    _fetchBirthYear();
    super.initState();
  }

  Future<void> _fetchBirthYear() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('birthYear')) {
        final String fullBirthDate = doc.data()!['birthYear'].toString();

        if (fullBirthDate.contains('-')) {
          setState(() {
            _storedBirthYear = fullBirthDate.split('-')[0];
          });
        } else {
          _storedBirthYear = '2000';
        }
      } else {
        _storedBirthYear = '2000';
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });
    }
  }

  void _onOkPressed() {
    if (_enteredPin.length == 4) {
      if (_enteredPin == _storedBirthYear) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorText = 'Incorrect year. Try again!';
          _enteredPin = '';
        });
      }
    }
  }

  void _onClearPressed() {
    setState(() {
      _enteredPin = '';
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFADDEE0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBE9DF), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Parents Only',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Aleo',
                        color: Color(0xFFBF8C33),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'Please enter the user\'s birth year:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Aleo',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5E4828),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  _enteredPin.padRight(4, '_').split('').join('      '),
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'Luckiest Guy',
                    color: Color(0xFFBF8C33),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 250,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        return const SizedBox();
                      }
                      if (index == 11) {
                        return _buildKeyboardButton(
                          label: 'OK',
                          onTap: _onOkPressed,
                          isOkButton: true,
                        );
                      }
                      final number = index < 9 ? (index + 1).toString() : '0';
                      return _buildKeyboardButton(
                        label: number,
                        onTap: () => _onNumberPressed(number),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: _onClearPressed,
                  child: const Text('Clear'),
                ),
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

  Widget _buildKeyboardButton({
    required String label,
    required VoidCallback onTap,
    bool isOkButton = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isOkButton ? const Color(0xFFBF8C33) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Luckiest Guy',
            color: isOkButton ? Colors.white : const Color(0xFFBF8C33),
          ),
        ),
      ),
    );
  }
}
