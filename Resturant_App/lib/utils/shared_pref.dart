import 'package:shared_preferences/shared_preferences.dart';

class LocalSharedPrefDatabase {
  static SharedPreferences? pref;

  static const _languageIndexKey = 'languageKey';
  static const _emailKey = 'emailKey';
  static const _activityKey = 'activityKey';

  static Future init() async {
    pref = await SharedPreferences.getInstance();
  }

  static Future setLanguageIndex(int index) async {
    await pref!.setInt(_languageIndexKey, index);
  }

  static getLanguageIndex() {
    return pref!.getInt(_languageIndexKey);
  }

  static Future setUserEmail(String email) async {
    await pref!.setString(_emailKey, email);
  }

  static String? getUserEmail() {
    return pref!.getString(_emailKey);
  }


  static Future setActivity(String encodedActivityMap) async {
    await pref!.setString(_activityKey, encodedActivityMap);
  }

  static String? getActivity() {
    return pref!.getString(_activityKey);
  }

  static logout() {
    pref!.clear();
  }
}
