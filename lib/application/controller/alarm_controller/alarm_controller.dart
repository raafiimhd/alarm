import 'package:alarm_demo/domain/models/alarm_info/alarm_info.dart';
import 'package:alarm_demo/main.dart';
import 'package:alarm_demo/application/presentation/data/service/alarm_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmController extends GetxController {
  var alarmTime = DateTime.now().obs;
  var alarmTimeString = ''.obs;
  var isRepeatSelected = false.obs;
  var alarms = <AlarmInfo>[].obs;

  final AlarmHelper _alarmHelper = AlarmHelper();

 @override
void onInit() {
  alarmTimeString.value = DateFormat('HH:mm').format(alarmTime.value);
  _alarmHelper.initializeDatabase().then((value) {
    print('------database initialized');
    loadAlarms(); // Load alarms to ensure the latest data is displayed
  });
  super.onInit();
}


  void loadAlarms() async {
    var loadedAlarms = await _alarmHelper.getAlarms();
    alarms.assignAll(loadedAlarms);
  }

  void scheduleAlarm(DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo,
      {required bool isRepeating}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'codex_logo',
      sound: RawResourceAndroidNotificationSound(
          'android_app_src_main_res_raw_a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    if (isRepeating) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Office',
        alarmInfo.title,
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Office',
        alarmInfo.title,
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void onSaveAlarm(bool isRepeating) {
    DateTime? scheduleAlarmDateTime;
    if (alarmTime.value.isAfter(DateTime.now()))
      scheduleAlarmDateTime = alarmTime.value;
    else
      scheduleAlarmDateTime = alarmTime.value.add(Duration(days: 1));

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      gradientColorIndex: alarms.length,
      title: 'alarm',
    );
    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo, isRepeating: isRepeating);
    loadAlarms();
    Get.back();
  }

  void deleteAlarm(int? id) {
    _alarmHelper.delete(id);
    loadAlarms();
  }

  void updateExistingAlarm(AlarmInfo alarm,bool isRepeating) {
  int index = alarms.indexWhere((a) => a.id == alarm.id);
  if (index != -1) {
    alarms[index] = alarm;
    flutterLocalNotificationsPlugin.cancel(alarm.id!);

    // Reschedule the alarm with updated time
    scheduleAlarm(alarm.alarmDateTime!, alarm, isRepeating: isRepeating);

    // Refresh the alarm list
    alarms.refresh();
    _alarmHelper.updateAlarm(alarm); // Ensure this method updates the alarm in the database
  }
}



  void updateAlarmTime(DateTime selectedDateTime) {
    alarmTime.value = selectedDateTime;
    alarmTimeString.value = DateFormat('HH:mm').format(selectedDateTime);
  }

  void toggleRepeatSelection(bool value) {
    isRepeatSelected.value = value;
  }
}
