import 'dart:async';
import 'dart:io';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CamScreen(),
    );
  }
}

class CamScreen extends StatefulWidget {
  @override
  _CamScreenState createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  CameraController controller;
  DragController dragController = DragController();
  bool started = false;
  List takenPhotos = [];

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[1], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<File> capturePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String filePath = '${extDir.path}/${timestamp()}.png';

    print('fileeeee' + filePath.toString());

    try {
      await controller.takePicture(filePath).then((value) {
        print('capturedddd');
      });
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return File(filePath);
  }

  void captureImages() async {
    const fiveSec = const Duration(seconds: 5);
    new Timer.periodic(fiveSec, (Timer t) async {
      await capturePicture().then((value) {
        print(value);
        if (value != null) {
          takenPhotos.add(value.path.toString());
        }
        setState(() {});
        print('TAKEN');
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (!controller.value.isInitialized) {
      started = false;
      setState(() {});
      return Container();
    } else {
      if (started == false) {
        started = true;
        captureImages();
        setState(() {});
      }

      return Scaffold(
        body: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              color: Colors.red,
              child: ListView.builder(
                  itemCount: takenPhotos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(takenPhotos[index]),
                      ),
                    );
                  }),
            ),
            DraggableWidget(
              bottomMargin: 10,
              topMargin: 10,
              intialVisibility: true,
              horizontalSapce: 10,
              child: Container(
                  height: size.height * 0.25,
                  width: size.width * 0.25,
                  child: CameraPreview(controller)),
              initialPosition: AnchoringPosition.bottomLeft,
              dragController: dragController,
            )
          ],
        ),
      );
    }
  }
}
