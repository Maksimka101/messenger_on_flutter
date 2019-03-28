import 'dart:async';
import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/main_screen_bloc.dart';
import 'package:messenger_for_nou/models/chat_item_model.dart';
import 'package:messenger_for_nou/ui/chat_item.dart';
import 'package:messenger_for_nou/utils/cache.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final MainScreenBloc _mainScreenBloc = MainScreenBloc();
  Stream<List<ChatItem>> _chatsStream;

  Widget _builBody() => FutureBuilder<List<ChatItem>>(
        future: Cache.getChats(),
        builder: (context, snapshot) => StreamBuilder<List<ChatItem>>(
              stream: _chatsStream,
              initialData: snapshot.data,
              builder: (context, data) {
                if (data.data != null && data.data.isNotEmpty)
                  return ListView.builder(
                    itemCount: data.data.length,
                    itemBuilder: (context, id) {
                      Cache.addChat(data.data[id]);
                      return Column(
                        children: <Widget>[
                          ChatUnit(
                            chatItem: data.data[id],
                          ),
                          Divider(
                            height: 0,
                            indent: 60,
                          ),
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
            ),
      );

  @override
  void initState() {
    _chatsStream = _mainScreenBloc.getItemsStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your chats"),
      ),
      body: WillPopScope(
        child: _builBody(),
        onWillPop: () async => false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => _mainScreenBloc.addChat(context),
      ),
    );
  }

  @override
  void dispose() {
    _mainScreenBloc.dispose();
    super.dispose();
  }
}
