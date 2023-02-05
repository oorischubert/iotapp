import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSettings {
  static SharedPreferences? _preferences;

  static const _keyDevice = 'keyDevice';
  static const _keyDevList = 'keyDeviceList12';

//initializer
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

//sets currently selected device
  static Future setDevice(int device) async =>
      await _preferences?.setInt(_keyDevice, device);

  static int getDevice() => _preferences?.getInt(_keyDevice) ?? 0;

//json list of device names and their keys
  static Future setDeviceList(String deviceList) async =>
      await _preferences?.setString(_keyDevList, deviceList);

  static String getDeviceList() =>
      _preferences?.getString(_keyDevList) ??
      json.encode([
        {"name": "", "key": ""},
      ]); //change to empty list once add device implemented (done)
}

//provides instances for Provider!
class UserProvider extends ChangeNotifier {
  int _device = 0;
  int get device => _device;

  String _deviceList = json.encode([
    {"name": "", "key": ""}
  ]);
  String get deviceList => _deviceList;

  //initializer
  UserProvider() {
    getDevice();
    getDeviceList();
  }

  getDevice() async {
    _device = UserSettings.getDevice();
    notifyListeners();
  }

  set device(int value) {
    _device = value;
    UserSettings.setDevice(value);
    notifyListeners();
  }

  getDeviceList() async {
    _deviceList = UserSettings.getDeviceList();
    notifyListeners();
  }

  set deviceList(String value) {
    _deviceList = value;
    UserSettings.setDeviceList(value.toString());
    notifyListeners();
  }
}
