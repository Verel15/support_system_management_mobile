import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

@lazySingleton
class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  bool get hasSeenOnboarding => _prefs.getBool(StorageKeys.hasSeenOnboarding) ?? false;

  Future<void> markSeen() => _prefs.setBool(StorageKeys.hasSeenOnboarding, true);
}
