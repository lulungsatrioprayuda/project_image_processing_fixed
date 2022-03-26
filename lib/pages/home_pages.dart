import 'dart:io';

import 'package:project_image_processing_fixed/colors.dart';
import 'package:project_image_processing_fixed/pages/view-image-screen.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading;
  Image _image;
  XFile _imagePath;
  List _prediction;
  String _label;
  String _confidence;
  TextStyle textStylePrimary = GoogleFonts.openSans(
    textStyle: TextStyle(color: ThemeColor.SECONDARY_LIGHT, fontSize: 18.0),
  );

  TextStyle textStyleSecondary = GoogleFonts.openSans(
    textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: ThemeColor.SECONDARY,
        fontSize: 18.0),
  );

  @override
  void initState() {
    super.initState();
    _loading = true;
    load().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.PRIMARY_DARK,
      body: Container(
        padding: EdgeInsets.only(
          top: 150,
          left: 50,
          right: 50,
          bottom: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 300.0,
                child: selectImage(),
              ),
            ),
            SizedBox(height: 50),
            selectText(),
            SizedBox(height: 50),
            displayIcons(),
            SizedBox(height: 50),
            viewImage(),
          ],
        ),
      ),
    );
  }

  load() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  pickImage() async {
    var imagePicker =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (ImagePicker == null) return null;

    setState(() {
      _loading = true;
      _imagePath = imagePicker;
      _image = Image.file(File(imagePicker.path));
    });

    predict(imagePicker);
  }

  pickImageFromCamera() async {
    var imagePicker = await ImagePicker().pickImage(source: ImageSource.camera);

    if (ImagePicker == null) return null;

    setState(() {
      _loading = true;
      _imagePath = imagePicker;
      _image = Image.file(
        File(imagePicker.path),
      );
    });

    predict(imagePicker);
  }

  predict(XFile image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.5,
    );

    setState(() {
      _loading = false;
      _prediction = prediction;
      _label = transform(_prediction[0]['label']);
      _confidence = convert(_prediction[0]['confidence']);
    });
  }

  String transform(str) {
    String label = str.replaceAll(RegExp(r'[0-9 | s]'), '');
    label = label.toLowerCase();
    return label;
  }
}
