import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25.0,
              child: Icon(
                Icons.person,
                size: 30.0,
              ),
            ),
            const SizedBox(width: 20.0),
            Text(
              text,
              style: TextStyle(fontFamily: "Aleo", fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
