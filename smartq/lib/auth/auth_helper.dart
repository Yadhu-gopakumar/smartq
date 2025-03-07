import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    return token;
  }
}
