import 'dart:core';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
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
    loadMoreMessages();
  }

  final String chatName;
  final String friendName;
  final List<String> messagesByDate;
  String _currentDate;
  List<Message> _previousMessages = [];
  int _lastLoadDateIndex;
  int _lastId = 0;
  var _newMessages = <Message>[];

  final _messagesStream = PublishSubject<List<Message>>();

  Observable<List<Message>> getStreamForUi() {
    _listenForMessages();
    return _messagesStream.stream;
  }

  final _inputStream = PublishSubject<String>();

  StreamSink<String> getInputStream() {
    _listenForInput();
    return _inputStream.sink;
  }

  loadMoreMessages() {
    print(messagesByDate);
    if (_lastLoadDateIndex > 0 &&
        messagesByDate[_lastLoadDateIndex] == _currentDate) {
      _lastLoadDateIndex--;
    }
    if (_lastLoadDateIndex >= 0) {
      FirestoreRepository.getMessages(
              chatName, messagesByDate[_lastLoadDateIndex])
          .listen((messages) {
        if (messages.isNotEmpty)
          _previousMessages += sortMessagesById(messages);
          print(messages.length);
        _messagesStream.sink.add(_newMessages + _previousMessages);
      });
      _lastLoadDateIndex--;
    }
  }

  _listenForInput() => _inputStream.stream.listen((String messageText) {
        FirestoreRepository.sendMessage(
          createChatForNewDay: _currentDate != messagesByDate.last,
          chatName: chatName,
          data: messageText,
          time:
              "${DateTime.now().hour}:${DateTime.now().minute < 10 ? "0" : ""}"
              "${DateTime.now().minute}",
          senderId: User.userId,
          senderName: User.name,
          id: _lastId.toString(),
          currentDate: _currentDate,
        );
        _lastId++;
        if (_currentDate != messagesByDate.last)
          messagesByDate.add(_currentDate);
      });

  _listenForMessages() =>
      FirestoreRepository.getMessages(chatName, _currentDate)
          .listen((messages) {
        _newMessages = sortMessagesById(messages);
        _messagesStream.sink.add(_newMessages + _previousMessages);
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
}
