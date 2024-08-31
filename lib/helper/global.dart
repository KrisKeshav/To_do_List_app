import 'package:flutter/material.dart';

Color custom_green = const Color(0xff18DAA3);
Color bgColors = Colors.grey.shade100;

late Size mq;

void initMediaQuery(BuildContext context) {
  mq = MediaQuery.of(context).size;
}