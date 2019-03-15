import 'dart:core';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class ChatScreenBloc {
  ChatScreenBloc({
    this.chatName,
    this.friendName,
  });

  final String chatName;
  final String friendName;
  int _lastId = 0;

  final _messagesStream = BehaviorSubject<List<Message>>();

  Observable<List<Message>> getStreamForUi() {
    _listenForMessages();
    return _messagesStream.stream;
  }
  final _inputStream = BehaviorSubject<String>();

  StreamSink<String> getInputStream() {
    _listenForInput();
    return _inputStream.sink;
  }

  _listenForInput() =>
  _inputStream.stream.listen((String messageText) {
    FirestoreRepository.sendMessage(
        chatName: chatName,
        data: messageText,
        time: "${DateTime.now().hour}:${DateTime.now().minute}",
        senderId: User.userId,
        senderName: User.name,
        id: _lastId.toString(),
      );
      _lastId++;
  });

  _listenForMessages() =>
      FirestoreRepository.getMessages(chatName).listen((messages) {
      _messagesStream.sink.add(_sortMessagesById(messages).reversed.toList());
      if (messages != null) {
        for (Message i in messages) {
          int id = i.id;
          if (id > _lastId)
            _lastId = id;
        }
        _lastId++;
      }
    });


  dispose() {
    _messagesStream.close();
    _inputStream.close();
  }

  List<Message> _sortMessagesById(List<Message> messages) {
    for (int i = 0; i < messages.length; i++) {
      for (int j = 0; j < messages.length-i-1; j++) {
        if (messages[j].id > messages[j+1].id) {
          final tmp = messages[j];
          messages[j] = messages[j+1];
          messages[j+1] = tmp;
        }
      }
    }
    return messages;
  }

}
