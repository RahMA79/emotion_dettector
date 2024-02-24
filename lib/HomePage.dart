import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController cameraController;
  String output = '';

  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController.startImageStream((image) {
            runModel(image);
          });
        });
      }
    });
  }

  runModel(CameraImage image) async {
    dynamic recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    if (recognitions.isNotEmpty) {
      // Get the first recognition result
      var recognition = recognitions.first;
      String label = recognition['label'];
      double confidence = recognition['confidence'];
      String percentage = (confidence * 100).toStringAsFixed(2);

      setState(() {
        output = "$label - $percentage%";
      });
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCamera();

    loadModel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Emotion Detector',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              child: !cameraController.value.isInitialized
                  ? Container()
                  : ClipRect(
                      child: CameraPreview(cameraController),
                    )),
          Text(output),
        ],
      ),
    );
  }
}
