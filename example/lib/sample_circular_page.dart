import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SampleCircularPage extends StatefulWidget {
  @override
  _SampleCircularPageState createState() => _SampleCircularPageState();
}

class _SampleCircularPageState extends State<SampleCircularPage> {
  double percent = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Circular Percent Indicators"),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                percent = Random().nextDouble();
              });
            },
            child: CircularPercentIndicator(
              animation: true,
              animateFromLastPercent: true,
              reverse: true,
              gap: 20,
              radius: 300.0,
              lineWidth: 20.0,
              percent: percent,
              center: Text("${(percent * 100).toStringAsFixed(2)}%"),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey,
              maskFilter: MaskFilter.blur(BlurStyle.solid, 3),
              linearGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange, Colors.yellow],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
