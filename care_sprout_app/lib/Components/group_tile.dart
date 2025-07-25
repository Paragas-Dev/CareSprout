import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final String groupName;
  final VoidCallback onTap;

  const GroupTile({
    super.key,
    required this.groupName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(groupName),
      onTap: onTap,
    );
  }
}
