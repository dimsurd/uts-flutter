import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'presence_page.dart';

class CameraPage extends StatefulWidget {
  LatLng? iniPosition;
  String? address;
  String? id_user;
  CameraPage({Key? key, @required this.iniPosition, this.address, this.id_user})
      : super(key: key);
  @override
  State<CameraPage> createState() => _CameraPageState(
      initPosition: iniPosition, address: address, id_user: id_user);
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  LatLng? initPosition;
  String? address;
  String? id_user;
  _CameraPageState({this.initPosition, this.address, this.id_user});
  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller!.initialize();
  }

  Future<File?> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided_Camera';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}.jpg';
    try {
      XFile picture = await controller!.takePicture();
      picture.saveTo(filePath);
    } catch (e) {
      return null;
    }
    return File(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: initializeCamera(),
            builder: (_, snapshot) =>
                (snapshot.connectionState == ConnectionState.done)
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width *
                                    controller!.value.aspectRatio,
                                child: CameraPreview(controller!),
                              ),
                              Container(
                                width: 70,
                                height: 80,
                                margin: EdgeInsets.only(top: 10),
                                child: SingleChildScrollView(
                                  child: RaisedButton(
                                    onPressed: () async {
                                      if (!controller!.value.isTakingPicture) {
                                        File? result = await takePicture();
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                              builder: ((context) =>
                                                  new PresencePage(
                                                    imagefile: result,
                                                    initPosition: initPosition,
                                                    address: address,
                                                    id_user: id_user,
                                                  )),
                                            ));
                                      }
                                    },
                                    shape: CircleBorder(),
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width *
                                controller!.value.aspectRatio,
                          ),
                        ],
                      )
                    : Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        ),
                      )),
      ),
    );
  }

  RaisedButton(
      {required Future<Null> Function() onPressed,
      required CircleBorder shape,
      required MaterialColor color}) {}
}
