import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/add_chat_bloc.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';
import 'package:messenger_for_nou/utils/cache.dart';

class AddChatScreen extends StatefulWidget {
  @override
  _AddChatScreenState createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  final _inputController = TextEditingController();
  final _bloc = AddChatBloc();
  Stream<bool> _isExistStream;
  StreamSink<String> _userInput;
  BuildContext _context;

  // TODO it should be in bloc
  _listenForUserExist() {
    _bloc.getAnswerStream().listen((isExist) {
      if (isExist) {
        FirestoreRepository.addNewChat(
            sender1Id: User.id,
            sender2Id: _inputController.text.replaceAll(".", ""));
        Navigator.pop(_context);
      }
    });
  }

  @override
  void initState() {
    _listenForUserExist();
    _userInput = _bloc.getStreamForUserMail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return AlertDialog(
      content: StreamBuilder<bool>(
        stream: _isExistStream,
        initialData: false,
        builder: (context, data) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Write mail of exist user."),
              TextFormField(
                controller: _inputController,
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        RaisedButton(
          onPressed: () =>
              _userInput.add(_inputController.text.replaceAll(".", "")),
          child: Text("Start chat"),
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
