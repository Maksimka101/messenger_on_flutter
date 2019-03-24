
  import 'package:messenger_for_nou/models/message_model.dart';

List<Message> sortMessagesById(List<Message> messages) {
    for (int i = 0; i < messages.length; i++) {
      for (int j = 0; j < messages.length - i - 1; j++) {
        if (messages[j].id < messages[j + 1].id) {
          final tmp = messages[j];
          messages[j] = messages[j + 1];
          messages[j + 1] = tmp;
        }
      }
    }
    return messages;
  }
