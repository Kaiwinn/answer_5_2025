
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/task.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future scheduleTaskNotification(Task task) async {
    if (task.id == null) return;

    // Cancel any previous notification for this task
    await flutterLocalNotificationsPlugin.cancel(task.id!);
    
    // Only schedule notifications for tasks that are not completed
    if (task.status == 1) return;

    // Get current time
    final now = DateTime.now();
    
    // Only schedule notifications for future due dates
    if (task.dueDate.isBefore(now)) return;

    final timeString = '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}';
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      'Task Due: ${task.title}',
      'Due at $timeString: ${task.description}',
      tz.TZDateTime.from(task.dueDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_due_channel',
          'Task Due Notifications',
          channelDescription: 'Notifications for task due dates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}