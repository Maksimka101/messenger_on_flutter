import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/chat_screen_bloc.dart';
import 'package:messenger_for_nou/models/message_model.dart';
import 'package:messenger_for_nou/ui/message_item.dart';

// TODO
class ChatUi extends StatelessWidget {
  ChatUi(
      {@required this.companionName,
      @required this.chatId,
      @required this.messagesByDate});

  final String companionName;
  final String chatId;
  final List<String> messagesByDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(companionName[0]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("Chat with $companionName"),
            )
          ],
        ),
      ),
      body: ChatBody(
        companionName: companionName,
        chatName: chatId,
        messagesByDate: messagesByDate,
      ),
    );
  }
}

class ChatBody extends StatefulWidget {
  ChatBody(
      {@required this.companionName,
      @required this.chatName,
      @required this.messagesByDate});
  final List<String> messagesByDate;
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
    _firestore = ChatScreenBloc(
        messagesByDate: widget.messagesByDate,
        chatName: widget.chatName, friendName: widget.companionName);
    _uiBuildStream = _firestore.getStreamForUi();
    _inputStream = _firestore.getInputStream();
    super.initState();
  }

  Widget _inputMessageField() {
    return Row(
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4,),
            child: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              autocorrect: true,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              controller: _inputController,
              decoration: InputDecoration.collapsed(hintText: "Message"),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: Colors.deepOrange,),
          onPressed: () {
            if (_inputController.text != "") {
              _inputStream.add(_inputController.text.trim());
              _inputController.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _messagesList() => Expanded(
    child: StreamBuilder<List<Message>>(
      stream: _uiBuildStream,
      builder: (context, messages) {
        if (messages.data != null && messages.data.isNotEmpty) {
          if (messages.data.length < 400)
            _firestore.loadMoreMessages();
          return ListView.builder(
            reverse: true,
            controller: _listViewController,
            shrinkWrap: true,
            itemCount: messages.data.length,
            itemBuilder: (context, id) {
              return MessageItem.fromMessage(messages.data[id]);
            },
          );
        } else {
          return SpinKitRing(
            color: Colors.blue,
          );
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _messagesList(),
        _inputMessageField(),
      ],
    );
  }

  @override
  void dispose() {
    _firestore.dispose();
    super.dispose();
  }
}
