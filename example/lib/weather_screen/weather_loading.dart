import 'package:example/weather_screen/weather_data/my_location.dart';
import 'package:example/weather_screen/weather_data/network.dart';
import 'package:example/weather_screen/weather_screen.dart';
import 'package:flutter/material.dart';

const apiKey = '7a2a88dcfcb6ab8a79a2483118a48ade';

class data {
  var weatherData;
  var airData;
}

class WeatherLoading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<WeatherLoading> {
  late double latitude3;
  late double longitude3;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Future<data> getLocation() async {
    MyLocation myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    latitude3 = myLocation.latitude2;
    longitude3 = myLocation.longitude2;
    print(latitude3);
    print(longitude3);

    Network network = Network(
        'https://api.openweathermap.org/data/2.5/weather'
            '?lat=$latitude3&lon=$longitude3&appid=$apiKey&units=metric',
        'https://api.openweathermap.org/data/2.5/air_pollution'
            '?lat=$latitude3&lon=$longitude3&appid=$apiKey');

    var weatherData = await network.getJsonData();
    var airData = await network.getAirData();

    data wData = new data();
    wData.weatherData = weatherData;
    wData.airData = airData;

    return wData;

  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLocation(),
        initialData: new data(),
        builder: (BuildContext context, AsyncSnapshot<data> data) {
          if (data.data?.weatherData == null || data.data?.airData == null){
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: TextStyle(
                          fontSize: 15, )),
                  onPressed: (){
                  },
                  child: Text(
                    '날씨 정보를 가져오는 중 입니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gamja_Flower',
                    ),
                  ),
                ),
              ),
            );
          }else {
            return new WeatherScreen(
                parseWeatherData: data.data?.weatherData,
                parseAirPollution: data.data?.airData
            );
          }
        });
  }
}
