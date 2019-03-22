import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/main_screen_bloc.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/ui/chat_item.dart';

class MainChatsScreen extends StatelessWidget {
  final MainScreenBloc _mainScreenBloc = MainScreenBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your chats"),
      ),
      body: ChatsList(mainBloc: _mainScreenBloc),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.brush),
        onPressed: () => _mainScreenBloc.addChat(context),
      ),
    );
  }
}

class ChatsList extends StatefulWidget {
  ChatsList({@required this.mainBloc});
  final MainScreenBloc mainBloc;
  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  MainScreenBloc _mainBloc;
  Stream<List<ChatItem>> _chatsStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatItem>>(
      stream: _chatsStream,
      builder: (context, data) {
        if (data.data != null && data.data.isNotEmpty)
          return ListView.builder(
            itemCount: data.data.length,
            itemBuilder: (context, id) {
              return Column(
                children: <Widget>[
                  ChatUnit(chatItem: data.data[id],),
                  Divider(height: 0, indent: 60,),
                ],
              );
            },
          );
        else
          return Center(
            child: Text(
              "Nothing is here.\nPut on button to create new chat.",
              textAlign: TextAlign.center,
            ),
          );
      },
    );
  }

  @override
  void initState() {
    _mainBloc = widget.mainBloc;
    _chatsStream = _mainBloc.getItemsStream();
    super.initState();
  }

  @override
  void dispose() {
    _mainBloc.dispose();
    super.dispose();
  }
}
