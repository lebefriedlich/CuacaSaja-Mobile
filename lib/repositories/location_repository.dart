import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/models/location_code.dart';

class LocationRepository {
  static const String _locationsKey =
      'locations';
  Future<List<LocationCode>> get locationCodes async {
    final prefs = await SharedPreferences.getInstance();
    final String? locationsString = prefs.getString(_locationsKey);
    if (locationsString != null) {
      List<dynamic> json = jsonDecode(locationsString);
      return json
          .map((e) => LocationCode(code: e['code']))
          .toList();
    }
    return [];
  }

  Future<String> addLocationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final List<LocationCode> currentLocations = await locationCodes;

    if (currentLocations.length < 5) {
      if (!currentLocations.any((loc) => loc.code == code)) {
        currentLocations.add(LocationCode(code: code));
        String encodedData = jsonEncode(
            currentLocations.map((loc) => {'code': loc.code}).toList());
        await prefs.setString(_locationsKey, encodedData);

        return "Lokasi Berhasil Ditambahkan";
      } else {
        return "Lokasi Sudah Ada";
      }
    }
    return "Maksimal 5 Lokasi";
  }

  Future<bool> removeLocationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final List<LocationCode> currentLocations = await locationCodes;

    int initialLength = currentLocations.length;
    currentLocations.removeWhere((loc) => loc.code == code);
    if (currentLocations.length < initialLength) {
      String encodedData = jsonEncode(
          currentLocations.map((loc) => {'code': loc.code}).toList());
      await prefs.setString(_locationsKey,
          encodedData);
      return true;
    }
    return false;
  }

  Future<bool> checkData5() async {
    final List<LocationCode> currentLocations = await locationCodes;
    if (currentLocations.length < 5) {
      return true;
    }
    return false;
  }

  Future<bool> checkData() async {
    final List<LocationCode> currentLocations = await locationCodes;
    if (currentLocations.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<String> getCodeFirst() async {
    final List<LocationCode> currentLocations = await locationCodes;
    if (currentLocations.isNotEmpty) {
      return currentLocations.first.code;
    }
    return '';
  }
}
