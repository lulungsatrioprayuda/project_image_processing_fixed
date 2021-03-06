import 'dart:io';

import 'package:project_image_processing_fixed/colors.dart';
import 'package:project_image_processing_fixed/pages/view-image-screen.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pie_chart/pie_chart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
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
// 2. make function like this
  void updateMap() {
    print(_prediction);
    setState(() {
      _loading = true; // still sir
      // pick a image now
      _label = _prediction != null ? transform(_prediction[0]['label']) : '';
      print("Label: $_label");
      // and load the data map in here and my app is gonna be running
      // return dataMap = {
      //   "good air": select_result_pluss() ?? 0,
      //   "bad air": select_result_minus() ?? 0,
      // };
      // close statement
      if (_label == 'goodair') {
        return dataMap = {
          "good air": getResult() ?? 0,
          "bad air": 100 - (getResult() ?? 100),
        };
      } else if (_label == 'badquality') {
        return dataMap = {
          "good air": 100 - (getResult() ?? 100),
          "bad air": getResult() ?? 0,
        };
      } else {
        return dataMap = {
          "good air": 0,
          "bad air": 0,
        };
      }
    });
  }

  @override
  void initState() {
    super.initState();
    updateMap();
    _loading = true;
    load().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  // first making a map empty like this
  Map<String, double> dataMap = {};

  final legendLabels = <String, String>{
    "Good Air": "Good Air",
    "Bad Air": "Bad Air",
  };
  final colorList = <Color>[
    Color(0xFF4DBB53),
    Color(0xFFFF4848),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.PRIMARY_DARK,
      body: Container(
        padding: EdgeInsets.only(top: 150, left: 50, right: 50, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 300.0,
                child: PieChart(
                  dataMap: dataMap,
                  chartType: ChartType.ring,
                  baseChartColor: Colors.grey[50].withOpacity(0.15),
                  colorList: colorList,
                  chartValuesOptions: ChartValuesOptions(
                    showChartValuesInPercentage: true,
                  ),
                  totalValue: 100,
                ),
                //selectImage(),
              ),
            ),
            SizedBox(height: 50),
            selectText(),
            SizedBox(height: 30),
            displayIcons(),
            SizedBox(height: 30),
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

    if (imagePicker == null) return null;

    setState(() {
      _loading = true;
      _imagePath = imagePicker;
      _image = Image.file(File(imagePicker.path));
    });

    predict(imagePicker);
  }

  pickImageFromCamera() async {
    var imagePicker = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imagePicker == null) return null;

    setState(() {
      _loading = true;
      _imagePath = imagePicker;
      _image = Image.file(File(imagePicker.path));
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
      // _lola = _confidence;
      updateMap();
    });
  }

  String transform(str) {
    String label = str.replaceAll(RegExp(r'[0-9 | s]'), '');
    label = label.toLowerCase();
    return label;
  }

  String convert(value) {
    double confidence = value * 100;
    return confidence.toStringAsFixed(2);
  }

  // Image selectImage() {
  //   if (!_loading) {
  //     if (_label == 'goodair') return Image.asset('assets/images/good.png');
  //     if (_label == 'badquality')
  //       return Image.asset('assets/images/bad.png');
  //     else
  //       return Image.asset('assets/images/upload.png');
  //   } else
  //     return Image.asset('assets/images/load.png');
  // }

  double conv(value) {
    double convi = value * 100;
    return convi;
  }

  double getResult() {
    if (_prediction == null) return null;
    var result_plus = conv(_prediction[0]['confidence']);
    return result_plus;
  }

  // double select_result_minus() {
  //   if (_prediction == null) return null;
  //   var result = conv(_prediction[0]['confidence']);
  //   var result_minus = 100 - result;
  //   return result_minus;
  // }

  RichText selectText() {
    if (_prediction == null)
      return RichText(
        text: TextSpan(
          text: 'You can monitoring Air quality by upload image in your',
          style: textStylePrimary,
          children: [
            TextSpan(text: 'gallery ', style: textStyleSecondary),
            TextSpan(text: 'or from your ', style: textStylePrimary),
            TextSpan(text: 'camera ', style: textStyleSecondary),
            TextSpan(text: 'to get started!', style: textStylePrimary),
          ],
        ),
        textAlign: TextAlign.center,
      );
    else
      return RichText(
        text: TextSpan(
          text: 'Your air quality is a ',
          style: textStylePrimary,
          children: [
            TextSpan(text: _label, style: textStyleSecondary),
            TextSpan(
                text: ' with an accuracy image processing of ',
                style: textStylePrimary),
            TextSpan(text: '$_confidence%', style: textStyleSecondary),
          ],
        ),
        textAlign: TextAlign.center,
      );
  }

  Row displayIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          color: ThemeColor.PRIMARY,
          splashColor: ThemeColor.SECONDARY,
          splashRadius: 40,
          iconSize: 36,
          icon: Icon(Icons.drive_folder_upload),
          onPressed: pickImage,
        ),
        SizedBox(
          width: 25,
        ),
        IconButton(
          color: ThemeColor.PRIMARY,
          splashColor: ThemeColor.SECONDARY,
          splashRadius: 40,
          iconSize: 36,
          icon: Icon(Icons.camera_alt_outlined),
          onPressed: pickImageFromCamera,
        ),
      ],
    );
  }

  viewImage() {
    if (_image == null)
      return Container();
    else
      return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewImage(_imagePath)));
          },
          style: ElevatedButton.styleFrom(
            primary: ThemeColor.PRIMARY,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0.0,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Image',
                    style: GoogleFonts.openSans(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.arrow_forward_rounded)
                ]),
          ),
        ),
      );
  }
}
