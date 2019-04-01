import 'package:flutter/material.dart';
import 'package:messenger_for_nou/blocs/add_new_chat_bloc.dart';
import 'package:messenger_for_nou/models/user_model.dart';
import 'package:messenger_for_nou/resources/firestore_repository.dart';

class AddNewChat {
  static void createBottomSheet(BuildContext context) {
    final bloc = AddChatBloc();
    final controller = TextEditingController();
    final userIdInputStrem = bloc.sendUserIdFromUser();
    controller.addListener(() {
      if (controller.text.length > 0)
        userIdInputStrem.add(controller.text);
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: Colors.black87,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    fillColor: Colors.black,
                    hintText: "Enter id of your friend",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    )),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.white,
                child: StreamBuilder<List<User>>(
                  stream: bloc.getSuitableUsers(),
                  builder: (context, usersDoc) {
                    if (usersDoc.data != null && usersDoc.data.isNotEmpty)
                      return ListView.builder(
                        itemCount: usersDoc.data.length,
                        itemBuilder: (context, id) {
                          final currenUser = usersDoc.data[id];
                          return Column(
                            children: <Widget>[
                              InkWell(
                                splashColor: Colors.black,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 10),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        child: Text(
                                          currenUser.userName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            currenUser.userName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            currenUser.userId,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  FirestoreRepository.addNewChat(
                                    sender1Id: User.id,
                                    sender2Id: currenUser.userId,
                                  );
                                  Navigator.pop(context);
                                  controller.clear();
                                  userIdInputStrem.close();
                                  bloc.dispose();
                                },
                              ),
                              Divider(
                                height: 2,
                                indent: 60,
                                color: Colors.black54,
                              )
                            ],
                          );
                        },
                      );
                    else
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "No users found. Id length must be more than 3 characters",
                            softWrap: true,
                          ),
                        ],
                      );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
