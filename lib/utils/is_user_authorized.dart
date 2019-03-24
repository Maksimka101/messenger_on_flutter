import 'package:messenger_for_nou/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authorization {

  static const NAME = "name";
  static const ID = "id";

  static Future<bool> isUserAuthorized() async {
    final sp = await SharedPreferences.getInstance();
    final userName = sp.getString(NAME);
    final userId = sp.getString(ID);
    if (userId != null && userName != null) {
      User.userId = userId;
      User.name = userName;
      return true;
    } else
      return false;
  }
  
  static authorizeUser(String userName, String userId) async {
    User.name = userName;
    User.userId = userId;
    final sp = await SharedPreferences.getInstance();
    sp.setString(NAME, userName);
    sp.setString(ID, userId);
  }
  
}