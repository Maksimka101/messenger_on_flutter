import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:messenger_for_nou/models/message_model.dart' as Mesg;

class Notifications {
  static FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initialize() {
    final androidSettings = AndroidInitializationSettings("ic_launcher");
    final initSettings = InitializationSettings(androidSettings, null);
    Notifications._notificationsPlugin.initialize(initSettings);
  }

  static sendGoupMessage(
      {String senderName,
      String senderId,
      List<Mesg.Message> messages,
      String chatId}) async {
    final userPerson = Person(
      icon: senderName,
      key: senderId,
      name: senderName,
    );
    final notificationMessages = <Message>[];
    for (final msg in messages) {
      notificationMessages.add(msg.toNotificationMessage());
    }
    final messageStyle = MessagingStyleInformation(userPerson,
        messages: notificationMessages, groupConversation: false);
    final androidNotificationDetails = AndroidNotificationDetails(
      senderId,
      senderName,
      'messages',
      style: AndroidNotificationStyle.Messaging,
      styleInformation: messageStyle,
    );
    final platformSpecificNotifications =
        NotificationDetails(androidNotificationDetails, null);
    Notifications._notificationsPlugin.show(chatId.hashCode, "messages",
        "message body", platformSpecificNotifications);
  }

  static clearGroupMessage(String id) {
    Notifications._notificationsPlugin.cancel(id.hashCode);
  }
}
