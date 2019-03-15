class User {
  User({
    String userIdentity,
    String userName}) {
    if ( userIdentity != null)
      userId = userIdentity;
    if (userName != null)
      name = userName;
    print("$name, $userId");
  }

  // TODO
  static String name;
  static String userId;

  static User fromMap(Map<dynamic, dynamic> userMap) =>
      User(
        userIdentity: userMap["id"],
        userName: userMap["name"],
      );
}
