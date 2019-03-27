import 'package:flutter/material.dart';
import 'package:messenger_for_nou/models/message_model.dart';

class MessageItem extends StatelessWidget {
  MessageItem(
      {@required this.senderName,
      @required this.sendTime,
      @required this.messageText,
      @required this.isFromUser,
      this.isSeen,
      this.isFirst}) {
    if (isFirst != null && isFirst) {
      if (!isFromUser) {
        borderRadius.add(5);
        borderRadius.add(15);
        borderRadius.add(15);
        borderRadius.add(15);
      } else {
        borderRadius.add(15);
        borderRadius.add(15);
        borderRadius.add(15);
        borderRadius.add(5);
      }
    } else {
      borderRadius.add(isFromUser ? 15 : 5);
      borderRadius.add(isFromUser ? 15 : 5);
      borderRadius.add(isFromUser ? 5 : 15);
      borderRadius.add(isFromUser ? 5 : 15);
    }
  }

  final List<double> borderRadius = [];
  final String senderName;
  final String messageText;
  final String sendTime;
  final bool isFirst;
  // To show left or right
  final bool isFromUser;
  final bool isSeen;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Card(
              margin: isFromUser
                  ? EdgeInsets.only(left: 50, right: 5, bottom: 4, top: 3)
                  : EdgeInsets.only(left: 5, right: 50, bottom: 4, top: 3),
              color: isFromUser ? Colors.white : Colors.black54,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius[0]),
                bottomLeft: Radius.circular(borderRadius[1]),
                bottomRight: Radius.circular(borderRadius[2]),
                topRight: Radius.circular(borderRadius[3]),
              )),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: isFromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        messageText,
                        style: TextStyle(
                          fontSize: 15,
                          color: isFromUser ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          sendTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: isFromUser ? Colors.black : Colors.white,
                          ),
                        ),
                        isSeen != null
                            ? isSeen
                                ? Container()
                                : Text(
                                    "・",
                                    style: TextStyle(fontSize: 11),
                                  )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
  }

  static MessageItem fromMessage(Message message) => MessageItem(
        isFromUser: message.isFromUser,
        sendTime: message.sendTime,
        messageText: message.messageText,
        senderName: message.senderName,
        isSeen: message.isFromUser ? message.isSeen : true,
        isFirst: message.isFirst,
      );
}
