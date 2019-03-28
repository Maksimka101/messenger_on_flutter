import 'package:messenger_for_nou/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authorization {

  static const NAME = "name";
  static const ID = "id";
  static const MAIL = "mail";

  static Future<bool> isUserAuthorized() async {
    final sp = await SharedPreferences.getInstance();
    final userName = sp.getString(NAME);
    final userId = sp.getString(ID);
    final userMail = sp.getString(MAIL);
    if (userId != null && userName != null) {
      User.id = userId;
      User.name = userName;
      User.mail = userMail;
      return true;
    } else
      return false;
  }
  
  static authorizeUser(String userName, String userId, String userMail) async {
    User.name = userName;
    User.id = userId;
    final sp = await SharedPreferences.getInstance();
    sp.setString(NAME, userName);
    sp.setString(ID, userId);
    sp.setString(MAIL, userMail);
  }
  
}