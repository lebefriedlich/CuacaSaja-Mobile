import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/bmkg_model.dart';
import 'package:intl/intl.dart';

class BmkgRepository {
  final String baseUrl = 'https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=';

  Future<List<BMKGModel>> fetchBMKG(String kode) async {
    final response = await http.get(Uri.parse('$baseUrl$kode'));
    print('$baseUrl$kode');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<BMKGModel> weatherList = [];
      DateTime now = DateTime.now();

      if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
        for (var item in jsonData['data']) {
          if (item['cuaca'] != null && item['cuaca'].isNotEmpty) {
            List<dynamic> cuacaList = item['cuaca'][0];

            BMKGModel? selectedWeather;

            for (var weatherItem in cuacaList) {
              String localDatetimeString = weatherItem['local_datetime'];
              DateTime weatherTime =
                  DateFormat('yyyy-MM-dd HH:mm').parse(localDatetimeString);

              if (weatherTime.isAfter(now.subtract(const Duration(hours: 3))) &&
                  weatherTime.isBefore(now.add(const Duration(hours: 3)))) {
                var temperature = weatherItem['t'];
                if (temperature is String) {
                  temperature = double.tryParse(temperature) ?? 0.0;
                } else if (temperature is! double) {
                  temperature = temperature.toDouble();
                }

                selectedWeather = BMKGModel(
                  localDatetime: localDatetimeString,
                  temperature: temperature,
                  temperatureCondition: weatherItem['tcc'].toString(),
                  weatherDescription: weatherItem['weather_desc'].toString(),
                  humidity:
                      double.tryParse(weatherItem['hu'].toString()) ?? 0.0,
                  windSpeed:
                      double.tryParse(weatherItem['ws'].toString()) ?? 0.0,
                  visibilityText: weatherItem['vs_text'].toString(),
                  image: weatherItem['image'].toString(),
                  village: item['lokasi']['desa'].toString(),
                );
                break;
              }
            }

            if (selectedWeather == null) {
              DateTime closestWeatherTime = DateTime.now()
                  .subtract(const Duration(hours: 3));
              for (var weatherItem in cuacaList) {
                String localDatetimeString = weatherItem['local_datetime'];
                DateTime weatherTime =
                    DateFormat('yyyy-MM-dd HH:mm').parse(localDatetimeString);

                if (weatherTime.isBefore(now) &&
                    weatherTime.isAfter(closestWeatherTime)) {
                  var temperature = weatherItem['t'];
                  if (temperature is String) {
                    temperature = double.tryParse(temperature) ?? 0.0;
                  } else if (temperature is! double) {
                    temperature = temperature.toDouble();
                  }

                  selectedWeather = BMKGModel(
                    localDatetime: localDatetimeString,
                    temperature: temperature,
                    temperatureCondition: weatherItem['tcc'].toString(),
                    weatherDescription: weatherItem['weather_desc'].toString(),
                    humidity:
                        double.tryParse(weatherItem['hu'].toString()) ?? 0.0,
                    windSpeed:
                        double.tryParse(weatherItem['ws'].toString()) ?? 0.0,
                    visibilityText: weatherItem['vs_text'].toString(),
                    image: weatherItem['image'].toString(),
                    village: item['lokasi']['desa'].toString(),
                  );
                  closestWeatherTime = weatherTime;
                }
              }
            }
            if (selectedWeather != null) {
              weatherList.add(selectedWeather);
            }
          }
        }
      }

      return weatherList;
    } else if (response.statusCode == 404) {
      throw Exception('Data BMKG Tidak Tersedia, Coba Pilih Daerah Lain');
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
