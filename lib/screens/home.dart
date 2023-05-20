// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:weather/models/forecast_result.dart';
import 'package:weather/models/weather_result.dart';
import 'package:weather/network/open_weather_map_client.dart';
import 'package:weather/state/state.dart';
import '../const/const.dart';
import '../utils/utils.dart';
import '../widgets/fore_cast_tile_widget.dart';
import '../widgets/info_widget.dart';
import '../widgets/weather_tile_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(MyStateController());
  var location = Location();
  late StreamSubscription listener;
  late PermissionStatus permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await enableLocationListener();
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.clamp,
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: const [
                  Color(colorBgl1),
                  Color(colorBgl2),
                ],
              ),
            ),
            child: controller.locationData.value.latitude != null
                ? FutureBuilder(
                    future: OpenWeatherMapClient()
                        .getWeather(controller.locationData.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(snapshot.error.toString(),
                                style: const TextStyle(color: Colors.white)));
                      } else if (snapshot.hasData) {
                        return Center(
                          child: Text('No Data',
                              style: TextStyle(color: Colors.white)),
                        );
                      } else {
                        var data = snapshot.data as WeatherResult;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: height * 0.1),
                            WeatherTileWidget(
                              context: context,
                              title:
                                  (data.name != null && data.name!.isNotEmpty)
                                      ? data.name
                                      : '${data.coord!.lat}/${data.coord!.lon}',
                              titleFontSize: 30,
                              subTitle: DateFormat('dd-MM-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      (data.dt ?? 0) * 1000)),
                            ),
                            SizedBox(height: height * 0.09),
                            Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    buildIcon(data.weather![0].icon ?? ''),
                                height: height * 0.2,
                                width: width * 0.4,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.image, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: height * 0.05),
                            WeatherTileWidget(
                              context: context,
                              title: '${data.main!.temp}°C',
                              titleFontSize: 60,
                              subTitle: '${data.weather![0].description}',
                            ),
                            SizedBox(height: height * 0.1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: width / 8),
                                InfoWidget(
                                  icon: FontAwesomeIcons.wind,
                                  text: '${data.wind!.speed} m/s',
                                ),
                                InfoWidget(
                                  icon: FontAwesomeIcons.cloud,
                                  text: '${data.clouds!.all} %',
                                ),
                                InfoWidget(
                                  icon: FontAwesomeIcons.snowflake,
                                  text: data.snow != null
                                      ? '${data.snow!.d1h}'
                                      : '0',
                                ),
                                SizedBox(width: width / 8),
                              ],
                            ),
                            SizedBox(height: height * 0.1),
                            Expanded(
                                child: FutureBuilder(
                                    future: OpenWeatherMapClient().getForecast(
                                        controller.locationData.value),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                snapshot.error.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white)));
                                      } else if (snapshot.hasData) {
                                        return Center(
                                          child: Text('No Data',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        );
                                      } else {
                                        var data =
                                            snapshot.data as ForecastResult;
                                        return ListView.builder(
                                          itemCount: data.list!.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            var item = data.list![index];
                                            return ForeCastTileWidget(
                                                imageUrl: buildIcon(
                                                    item.weather![0].icon ?? '',
                                                    isBigSize: false),
                                                temp: '${item.main!.temp}°C',
                                                time: DateFormat('HH:mm')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            (item.dt ?? 0) *
                                                                1000)));
                                          },
                                        );
                                      }
                                    })),
                          ],
                        );
                      }
                    })
                : const Center(
                    child: Text('Waiting...',
                        style: TextStyle(color: Colors.white)),
                  ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          controller.locationData.value = await location.getLocation();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> enableLocationListener() async {
    controller.isEnableLocation.value = await location.serviceEnabled();
    if (!controller.isEnableLocation.value) {
      controller.isEnableLocation.value = await location.requestService();
      if (!controller.isEnableLocation.value) {
        return;
      }
    }
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    controller.locationData.value = await location.getLocation();
    listener =
        location.onLocationChanged.listen((LocationData currentLocation) {
      controller.locationData.value = currentLocation;
    });
  }
}
