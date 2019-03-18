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
    this.messagesByDate,
  }) {
    final date = DateTime.now();
    _currentDate = "${date.day} ${date.month} ${date.year}";
    _lastLoadDateIndex = messagesByDate.length - 1;
    _loadPreviousMessages(messagesByDate.last);
  }

  final String chatName;
  final String friendName;
  final List<String> messagesByDate;
  String _currentDate;
  List<Message> _previousMessages = [];
  int _lastLoadDateIndex;
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

  loadMoreMessages() {
    if (_lastLoadDateIndex > 0) {
      _lastLoadDateIndex--;
      FirestoreRepository.getMessages(
          chatName, messagesByDate[_lastLoadDateIndex])
          .listen((messages) {
        if (messages.isNotEmpty)
          _previousMessages =
              _sortMessagesById(messages + _previousMessages).reversed.toList();
      });
    }
  }

  _loadPreviousMessages(String date) {
    if (date != _currentDate)
      FirestoreRepository.getMessages(chatName, date).listen((messages) {
        if (messages.isNotEmpty)
          _previousMessages = _sortMessagesById(messages).reversed.toList();
      });
  }

  _listenForInput() => _inputStream.stream.listen((String messageText) {
        FirestoreRepository.sendMessage(
          createChatForNewDay: false,
          chatName: chatName,
          data: messageText,
          time: "${DateTime.now().hour}:${DateTime.now().minute}",
          senderId: User.userId,
          senderName: User.name,
          id: _lastId.toString(),
          currentDate: _currentDate,
        );
        _lastId++;
      });

  _listenForMessages() =>
      FirestoreRepository.getMessages(chatName, _currentDate)
          .listen((messages) {
        _messagesStream.sink.add(
            _previousMessages + _sortMessagesById(messages).reversed.toList());
        if (messages != null) {
          for (Message i in messages) {
            int id = i.id;
            if (id > _lastId) _lastId = id;
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
      for (int j = 0; j < messages.length - i - 1; j++) {
        if (messages[j].id > messages[j + 1].id) {
          final tmp = messages[j];
          messages[j] = messages[j + 1];
          messages[j + 1] = tmp;
        }
      }
    }
    return messages;
  }
}
