import 'dart:convert';

import 'package:fast_app_base/common/cli_common.dart';
import 'package:fast_app_base/common/widget/animated_number_text.dart';
import 'package:fast_app_base/common/widget/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import '../../common/common.dart';
import 'w_menu_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final wsUrl = Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@trade');
  late final channel = IOWebSocketChannel.connect(wsUrl);
  late final Stream<dynamic> stream;

  String priceString = 'Loading';
  final List<double> priceList = [];

  final intervalDuration = 1.seconds;
  DateTime lastUpdatedTime = DateTime.now();

  @override
  void initState() {
    stream = channel.stream;
    stream.listen((event) {
      final obj = json.decode(event);
      final double price = double.parse(obj['p']);

      if (DateTime.now().difference(lastUpdatedTime) > intervalDuration) {
        lastUpdatedTime = DateTime.now();
        setState(() {
          priceList.add(price);
          // 소수점 2자리 끊기
          priceString = price.toDoubleStringAsFixed();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedNumberText(
                priceString,
                textStyle: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
                duration: 50.ms,
              ),
              LineChartWidget(
                priceList,
                maxPrice: 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
