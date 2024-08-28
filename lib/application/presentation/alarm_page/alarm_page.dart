import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:alarm_demo/application/controller/alarm_controller/alarm_controller.dart';
import 'package:alarm_demo/application/controller/location_controller/location_controller.dart';
import 'package:alarm_demo/domain/core/colors/colors.dart';
import 'package:dotted_border/dotted_border.dart';

class AlarmPage extends StatelessWidget {
  final AlarmController alarmController = Get.put(AlarmController());
  final LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Alarm',
              style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              var location = locationController.location.value;
              return Text(
                location ?? 'Fetching location...',
                style: TextStyle(
                  fontFamily: 'avenir',
                  color: CustomColors.primaryTextColor,
                  fontSize: 16,
                ),
              );
            }),
           
            Expanded(
              child: Obx(() {
                return ListView(
                  children: alarmController.alarms.map<Widget>((alarm) {
                    var alarmTime = DateFormat('hh:mm aa').format(alarm.alarmDateTime!);
                    var gradientColor = GradientTemplate.gradientTemplate[alarm.gradientColorIndex!].colors;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColor,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColor.last.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(4, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.label,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    alarm.title!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir',
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                onChanged: (bool value) {},
                                value: true,
                                activeColor: Colors.white,
                              ),
                            ],
                          ),
                          Text(
                            'Mon-Fri',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'avenir',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                alarmTime,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'avenir',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.white,
                                onPressed: () {
                                  alarmController.deleteAlarm(alarm.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList()
                    ..add(_buildAddAlarmButton(context)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAlarmButton(BuildContext context) {
    return alarmController.alarms.length < 5
        ? DottedBorder(
            strokeWidth: 2,
            color: CustomColors.clockOutline,
            borderType: BorderType.RRect,
            radius: Radius.circular(24),
            dashPattern: [5, 4],
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColors.clockBG,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: MaterialButton(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                onPressed: () {
                  alarmController.updateAlarmTime(DateTime.now());
                  showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Obx(() {
                                  return TextButton(
                                    onPressed: () async {
                                      var selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (selectedTime != null) {
                                        final now = DateTime.now();
                                        var selectedDateTime = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                        );
                                        alarmController.updateAlarmTime(selectedDateTime);
                                      }
                                    },
                                    child: Text(
                                      alarmController.alarmTimeString.value,
                                      style: TextStyle(fontSize: 32),
                                    ),
                                  );
                                }),
                                Obx(() {
                                  return ListTile(
                                    title: Text('Repeat'),
                                    trailing: Switch(
                                      onChanged: (value) {
                                        alarmController.toggleRepeatSelection(value);
                                      },
                                      value: alarmController.isRepeatSelected.value,
                                    ),
                                  );
                                }),
                                ListTile(
                                  title: Text('Sound'),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                ),
                                ListTile(
                                  title: Text('Title'),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                ),
                                FloatingActionButton.extended(
                                  onPressed: () {
                                    alarmController.onSaveAlarm(alarmController.isRepeatSelected.value);
                                  },
                                  icon: Icon(Icons.alarm),
                                  label: Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/add_alarm.png',
                      scale: 1.5,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add Alarm',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'avenir',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: Text(
              'Only 5 alarms allowed!',
              style: TextStyle(color: Colors.white),
            ),
          );
  }
}
