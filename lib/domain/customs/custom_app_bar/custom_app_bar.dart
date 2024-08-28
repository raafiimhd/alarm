import 'package:alarm_demo/domain/core/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
   CustomAppBar({super.key, required this.title,  this.leading, });
  final String title;
  IconButton? leading;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,style: TextStyle(color: CustomColors.primaryTextColor,fontWeight: FontWeight.bold)),
      leading: leading,

    );
  }
}
