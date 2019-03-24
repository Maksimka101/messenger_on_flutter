import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
import 'package:rxdart/rxdart.dart';

class ChatItemBloc {

  ChatItemBloc({
    this.chatId,
    this.date,
  }) {
    print(chatId+" "+date);
  }

  final String chatId, date;

  final _lastMessageStream =PublishSubject<Message>();
  Observable<Message> getLastMessageStream() {
    _listenForLastMessage();
    return _lastMessageStream.stream;
  }

  _listenForLastMessage() {
    FirestoreRepository.getMessages(chatId, date).listen((messages) {
      if (messages.isNotEmpty)
        _lastMessageStream.sink.add(sortMessagesById(messages).first);
    });
  }

  dispose() {
    _lastMessageStream.close();
  }
}