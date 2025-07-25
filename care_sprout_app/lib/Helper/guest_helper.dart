import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isGuestUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isGuest') ?? false;
}