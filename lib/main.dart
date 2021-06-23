import 'dart:async';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  Size size=MediaQuery.of(context).size;
   if (!controller.value.isInitialized) {
     print('not');
      return Container();
    }

    return Scaffold(
     body: Stack(
       children: [
         Container(
          height:size.height,
          width: size.width,
          color: Colors.red,
         ),
       

          DraggableWidget(
            bottomMargin: 10,
            topMargin: 10,
            intialVisibility: true,
            horizontalSapce: 10,
            child:Container(
             height: size.height*0.25,
             width: size.width*0.25,
             child: CameraPreview(controller)),
            initialPosition: AnchoringPosition.bottomLeft,
            dragController: dragController,
          )

       ],
     ),
    );
  }
}