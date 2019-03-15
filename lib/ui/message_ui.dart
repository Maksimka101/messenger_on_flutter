import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_screen_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/message_item.dart';

// TODO
class ChatUi extends StatelessWidget {
  ChatUi({@required this.companionName, @required this.chatId});

  final String companionName;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(companionName[0]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Chat with $companionName"),
            )
          ],
        ),
      ),
      body: ChatBody(companionName: companionName, chatName: chatId,),
    );
  }
}

class ChatBody extends StatefulWidget {
  ChatBody({@required this.companionName, @required this.chatName});
  final String companionName;
  final String chatName;
  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {

  ChatScreenBloc _firestore;
  Stream<List<Message>> _uiBuildStream;
  StreamSink<String> _inputStream;
  final _listViewController = ScrollController();
  final _inputController = TextEditingController();

  @override
  void initState() {
    _firestore = ChatScreenBloc(chatName: widget.chatName, friendName: widget.companionName);
    _uiBuildStream = _firestore.getStreamForUi();
    _inputStream = _firestore.getInputStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: _uiBuildStream,
            builder: (context, messages) {
              if (messages.data != null && messages.data.isNotEmpty) {

                Timer(Duration(milliseconds: 100), () =>
                    _listViewController.jumpTo(_listViewController
                        .position.maxScrollExtent));
                return ListView.builder(
                  controller: _listViewController,
                  shrinkWrap: true,
                  itemCount: messages.data.length,
                  itemBuilder: (context, id) {
                    return MessageItem.fromMessage(messages.data[id]);
                  },
                );
              } else {
                return SpinKitRing(color: Colors.blue,);
              }
            },
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: "Enter u message here"
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_inputController.text != "") {
                    _inputStream.add(_inputController.text);
                    _inputController.clear();
                  }
                },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _firestore.dispose();
    super.dispose();
  }
}
