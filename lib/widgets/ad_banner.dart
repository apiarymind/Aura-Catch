import 'package:flutter/material.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.grey[800],
      alignment: Alignment.center,
      child: const Text('AdMob Banner Placeholder', style: TextStyle(color: Colors.white70)),
    );
  }
}
