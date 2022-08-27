import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:obtainium/services/source_service.dart';

class ObtainiumNotification {
  late int id;
  late String title;
  late String message;
  late String channelCode;
  late String channelName;
  late String channelDescription;
  Importance importance;

  ObtainiumNotification(this.id, this.title, this.message, this.channelCode,
      this.channelName, this.channelDescription, this.importance);
}

class UpdateNotification extends ObtainiumNotification {
  UpdateNotification(List<App> updates)
      : super(
            2,
            'Updates Available',
            '',
            'UPDATES_AVAILABLE',
            'Updates Available',
            'Notifies the user that updates are available for one or more Apps tracked by Obtainium',
            Importance.max) {
    message = updates.length == 1
        ? '${updates[0].name} has an update.'
        : '${(updates.length == 2 ? '${updates[0].name} and ${updates[1].name}' : '${updates[0].name} and ${updates.length - 1} more apps')} have updates.';
  }
}

class ErrorCheckingUpdatesNotification extends ObtainiumNotification {
  ErrorCheckingUpdatesNotification(String error)
      : super(
            5,
            'Error Checking for Updates',
            error,
            'BG_UPDATE_CHECK_ERROR',
            'Error Checking for Updates',
            'A notification that shows when background update checking fails',
            Importance.high);
}

final completeInstallationNotification = ObtainiumNotification(
    1,
    'Complete App Installation',
    'Obtainium must be open to install Apps',
    'COMPLETE_INSTALL',
    'Complete App Installation',
    'Asks the user to return to Obtanium to finish installing an App',
    Importance.max);

final checkingUpdatesNotification = ObtainiumNotification(
    4,
    'Checking for Updates',
    '',
    'BG_UPDATE_CHECK',
    'Checking for Updates',
    'Transient notification that appears when checking for updates',
    Importance.min);

class NotificationsProvider {
  FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  bool isInitialized = false;

  Map<Importance, Priority> importanceToPriority = {
    Importance.defaultImportance: Priority.defaultPriority,
    Importance.high: Priority.high,
    Importance.low: Priority.low,
    Importance.max: Priority.max,
    Importance.min: Priority.min,
    Importance.none: Priority.min,
    Importance.unspecified: Priority.defaultPriority
  };

  Future<void> initialize() async {
    isInitialized = await notifications.initialize(const InitializationSettings(
            android: AndroidInitializationSettings('ic_notification'))) ??
        false;
  }

  Future<void> cancel(int id) async {
    if (!isInitialized) {
      await initialize();
    }
    await notifications.cancel(id);
  }

  Future<void> notifyRaw(
      int id,
      String title,
      String message,
      String channelCode,
      String channelName,
      String channelDescription,
      Importance importance,
      {bool cancelExisting = false}) async {
    if (cancelExisting) {
      await cancel(id);
    }
    if (!isInitialized) {
      await initialize();
    }
    await notifications.show(
        id,
        title,
        message,
        NotificationDetails(
            android: AndroidNotificationDetails(channelCode, channelName,
                channelDescription: channelDescription,
                importance: importance,
                priority: importanceToPriority[importance]!,
                groupKey: 'dev.imranr.obtainium.$channelCode')));
  }

  Future<void> notify(ObtainiumNotification notif,
          {bool cancelExisting = false}) =>
      notifyRaw(notif.id, notif.title, notif.message, notif.channelCode,
          notif.channelName, notif.channelDescription, notif.importance,
          cancelExisting: cancelExisting);
}
