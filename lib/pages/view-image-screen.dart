import 'dart:io';
import 'package:project_image_processing_fixed/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_image_processing_fixed/pages/home_pages.dart';

import 'package:pie_chart/pie_chart.dart';

class ViewImage extends StatelessWidget {
  final XFile image;

  Map<String, double> dataMap = {
    "good air": 51.1,
    "bad air": 49.4,
  };
  final legendLabels = <String, String>{
    "Good Air": "Good Air",
    "Bad Air": "Bad Air",
  };
  final colorList = <Color>[
    Color(0xFF4DBB53),
    Color(0xFFFF4848),
  ];
  ViewImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.PRIMARY_DARK,
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: ThemeColor.PRIMARY,
                size: 36,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height * 0.85,
              child: ClipRRect(
                child: Image.file(File(image.path)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
