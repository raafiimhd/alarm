import 'package:alarm_demo/application/presentation/alarm_page/alarm_page.dart';
import 'package:alarm_demo/domain/core/colors/colors.dart';
import 'package:alarm_demo/domain/customs/custom_app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body:  AlarmPage()
    );
  }
}
