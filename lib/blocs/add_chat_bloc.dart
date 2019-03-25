import 'dart:async';

import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:rxdart/rxdart.dart';
class AddChatBloc {


  // it gain user mail and check is this user exist
  final _userIdStream = PublishSubject<String>();
  StreamSink<String> getStreamForUserMail() {
    _listenForUserInput();
    return _userIdStream.sink;
  }

  // this stream yield true if user exist
  final _isExistStream = PublishSubject<bool>();
  Stream<bool> getAnswerStream() => _isExistStream.stream;


  _listenForUserInput() {
    _userIdStream.stream.listen((userId) {
      FirestoreRepository.getAllUsersId().listen((usersId) {
        if (usersId.contains(userId))
          _isExistStream.sink.add(true);
        else
          _isExistStream.sink.add(false);
      });
    });
  }

  dispose() {
    _userIdStream.close();
    _isExistStream.close();
  }

}