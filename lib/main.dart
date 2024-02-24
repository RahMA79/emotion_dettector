import 'package:camera/camera.dart';
import 'package:emotion_dettector/HomePage.dart';

import 'package:flutter/material.dart';

List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const EmotionDetector());
}

class EmotionDetector extends StatelessWidget {
  const EmotionDetector({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
