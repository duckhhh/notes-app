import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();
  final _box = GetStorage();
  final _key = 'isDarkMode';

  Future<ThemeService> init() async {
    await GetStorage.init();
    return this;
  }

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  
  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  
  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);
  
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
