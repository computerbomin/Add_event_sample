import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class WeatherModel {
  Widget? getWeatherIcon(int condition) {
    if (condition < 300) {
      return Image.asset(
        'image/climacon-colud_lightning.png',
        color: Colors.black87,
      );
    } else if (condition < 600) {
      return Image.asset(
        'image/climacon-cloud_rain.png',
        color: Colors.black87,
      );
    } else if (condition == 800) {
      return Image.asset(
        'image/climacon-sun.png',
        color: Colors.black87,
      );
    } else if (condition <= 804) {
      return Image.asset(
        'image/climacon-cloud_sun.png',
        color: Colors.black87,
      );
    }
  }

  Widget? getAirIcon(int index) {
    if (index == 1) {
      return Image.asset(
        'image/close.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 2) {
      return Image.asset(
        'image/standing.jpg',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 3) {
      return Image.asset(
        'image/ground.jpg',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 4) {
      return Image.asset(
        'image/speaking.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 5) {
      return Image.asset(
        'image/back.png',
        width: 37.0,
        height: 35.0,
      );
    }
  }

  Widget? getAirCondition(int index) {
    if (index == 1) {
      return Text(
        '"매우좋음"',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gamja_Flower',
        ),
      );
    } else if (index == 2) {
      return Text(
        '"좋음"',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gamja_Flower',
        ),
      );
    } else if (index == 3) {
      return Text(
        '"보통"',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gamja_Flower',
        ),
      );
    } else if (index == 4) {
      return Text(
        '"나쁨"',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gamja_Flower',
        ),
      );
    } else if (index == 5) {
      return Text(
        '"매우나쁨"',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gamja_Flower',
        ),
      );
    }
  }
}

