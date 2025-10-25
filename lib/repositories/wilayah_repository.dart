import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/wilayah_model.dart';

class WilayahRepository {
  final String baseUrl = 'https://wilayah-indonesia.mhna.my.id/api/wilayah';

  Future<List<Provinsi>> fetchProvinsi() async {
    final response = await http.get(Uri.parse('$baseUrl/provinsi'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> provinsiList = jsonData['data'];
      
      return provinsiList
          .map((item) => Provinsi.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<Kabupaten>> fetchKabupaten(String kodeProvinsi) async {
    final response = await http.get(Uri.parse('$baseUrl/kabupaten/$kodeProvinsi'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> kabupatenList = jsonData['data'];

      return kabupatenList.map((item) => Kabupaten.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load kabupaten');
    }
  }

  Future<List<Kecamatan>> fetchKecamatan(String kodeKabupaten) async {
    final response = await http.get(Uri.parse('$baseUrl/kecamatan/$kodeKabupaten'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> kecamatanList = jsonData['data'];

      return kecamatanList.map((item) => Kecamatan.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load kecamatan');
    }
  }

  Future<List<Desa>> fetchDesa(String kodeKecamatan) async {
    final response = await http.get(Uri.parse('$baseUrl/desa/$kodeKecamatan'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> desaList = jsonData['data'];

      return desaList.map((item) => Desa.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load desa');
    }
  }
}
