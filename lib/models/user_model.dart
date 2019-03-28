class User {
  User({
    this.userId,
    this.userName,
    this.userMail});

  final String userMail; 
  final String userName;
  final String userId;
  static String mail;
  static String name;
  static String id;

  static User fromMap(Map<dynamic, dynamic> userMap) =>
      User(
        userId: userMap["id"],
        userName: userMap["name"],
        userMail: userMap["mail"],
      );
}
