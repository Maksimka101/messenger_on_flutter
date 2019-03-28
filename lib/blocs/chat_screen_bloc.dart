import 'dart:core';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/sorting.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class ChatScreenBloc {
  ChatScreenBloc({
    this.chatId,
    this.messagesByDate,
  }) {
    final date = DateTime.now();
    _currentDate = "${date.day} ${date.month} ${date.year}";
    _lastLoadDateIndex = messagesByDate.length - 1;
    loadMoreMessages();
    _listenForLastSeenMessage();
    _listenForInput();
    _listenForLastSeenMessageId();
    _listenForMessages();
  }


  final String chatId;
  final List<String> messagesByDate;
  String _currentDate;
  var _previousMessages = <Message>[];
  int _lastLoadDateIndex;
  int _lastId = 0;
  int _lastSeenMessageId;
  var _newMessages = <Message>[];

  final _messagesStream = BehaviorSubject<List<Message>>();

  Observable<List<Message>> getStreamForUi() {
    return _messagesStream.stream;
  }

  final _inputStream = BehaviorSubject<String>();

  StreamSink<String> getInputStream() {
    return _inputStream.sink;
  }

  final _lastSeenMessageIdStream = BehaviorSubject<int>();

  StreamSink<int> getLastSeenMessageId() {
    return _lastSeenMessageIdStream.sink;
  }

  void _listenForLastSeenMessageId() => _lastSeenMessageIdStream.stream
      .listen((int id) => FirestoreRepository.setLastSeenMessageId(chatId, id));

  void loadMoreMessages() {
    if (_lastLoadDateIndex >= 0 &&
        messagesByDate[_lastLoadDateIndex] == _currentDate) {
      _lastLoadDateIndex--;
    }
    if (_lastLoadDateIndex >= 0) {
      FirestoreRepository.getMessages(
              chatId, messagesByDate[_lastLoadDateIndex])
          .listen((messages) {
        if (messages.isNotEmpty) {
          _previousMessages += sortMessagesById(messages);
          if (_previousMessages.first.id > _lastId)
            _lastId = _previousMessages.first.id + 1;
        }
        _messagesStream.sink.add(_prepareMessages(
            (_newMessages + _previousMessages), _lastSeenMessageId));
      });
      _lastLoadDateIndex--;
    }
  }

  void _listenForLastSeenMessage() =>
      FirestoreRepository.getLastSeenMessageId(chatId).listen((int lastSennId) {
        _lastSeenMessageId = lastSennId;
        _messagesStream.sink.add(
            _prepareMessages(_newMessages + _previousMessages, lastSennId));
      });

  void _listenForInput() => _inputStream.stream.listen((String messageText) {
        FirestoreRepository.sendMessage(
          createChatForNewDay: messagesByDate.isNotEmpty ? _currentDate != messagesByDate.last : true,
          chatName: chatId,
          data: messageText,
          time:
              "${DateTime.now().hour}:${DateTime.now().minute < 10 ? "0" : ""}"
              "${DateTime.now().minute}",
          senderId: User.id,
          senderName: User.name,
          id: _lastId.toString(),
          currentDate: _currentDate,
        );
        _lastId++;
        if (messagesByDate.isEmpty || _currentDate != messagesByDate.last)
          messagesByDate.add(_currentDate);
      });

  void _listenForMessages() =>
      FirestoreRepository.getMessages(chatId, _currentDate).listen((messages) {
        _newMessages = sortMessagesById(messages);
        print(_newMessages.length);
        _messagesStream.sink.add(_prepareMessages(
            (_newMessages + _previousMessages), _lastSeenMessageId));
        if (_newMessages.isNotEmpty && _newMessages.first.id > _lastId)
          _lastId = _newMessages.first.id;
        _lastId++;
      });

  // add "isSeen" and "ifFirst"
  List<Message> _prepareMessages(List<Message> messages, int id) {
    final _messages = <Message>[];
    for (int i = 0; i < messages.length - 1; i++) {
      if (id != null)
        messages[i].isSeen = messages[i].id <= id;
      else
        messages[i].isSeen = true;
      _messages.add(messages[i]);
    }
    return _messages;
  }

  dispose() {
    _lastSeenMessageIdStream.close();
    _messagesStream.close();
    _inputStream.close();
  }
}
