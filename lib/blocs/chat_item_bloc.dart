import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
import 'package:rxdart/rxdart.dart';

class ChatItemBloc {
  ChatItemBloc({
    this.chatId,
    this.date,
  });

  final String chatId, date;
  Message _lastMessage;
  int _lastSeenMessageId;

  final _lastMessageStream = PublishSubject<Message>();
  Observable<Message> getLastMessageStream() {
    _listenForLastMessage();
    _listenForLastSeenMessageId();
    return _lastMessageStream.stream;
  }

  void _listenForLastMessage() {
    FirestoreRepository.getMessages(chatId, date).listen((messages) {
      if (messages.isNotEmpty) {
        if (_lastSeenMessageId != null)
          _lastMessage.isSeen = _lastMessage.id <= _lastSeenMessageId;
        _lastMessage = sortMessagesById(messages).first;
        _lastMessageStream.sink.add(_lastMessage);
      }
    });
  }

  void _listenForLastSeenMessageId() =>
      FirestoreRepository.getLastSeenMessageId(chatId).listen((int id) {
        if (_lastMessage != null) {
          _lastMessage.isSeen = _lastMessage.id <= id;
          _lastSeenMessageId = id;
          _lastMessageStream.sink.add(_lastMessage);
        }
      });

  dispose() {
    _lastMessageStream.close();
  }
}
