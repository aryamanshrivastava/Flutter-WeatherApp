// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, unused_local_variable

import 'package:flutter/material.dart';

class WeatherTileWidget extends StatelessWidget {
  BuildContext? context;
  String? title;
  double? titleFontSize;
  String? subTitle;
  WeatherTileWidget({
    Key? key,
    this.context,
    this.title,
    this.titleFontSize,
    this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width= MediaQuery.of(context).size.width;
    double height= MediaQuery.of(context).size.height;
    return Column(
      children: [
        Center(
          child: Text(
            title ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: height*0.01,
        ),
        Center(
          child: Text(
            subTitle ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
