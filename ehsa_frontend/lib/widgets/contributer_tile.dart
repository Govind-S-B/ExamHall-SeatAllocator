import 'package:flutter/material.dart';

class ContributerTile extends StatelessWidget {
  final String name;
  final String role , profile , avatar;

  ContributerTile({
    Key? key,
    required this.name,
    required this.role,
    required this.profile,
    required this.avatar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      
      elevation: 0, // Control the elevation/shadow of the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             CircleAvatar(
              foregroundImage: NetworkImage(avatar),
                 radius: 30,
                // You can add avatar properties here
                ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
