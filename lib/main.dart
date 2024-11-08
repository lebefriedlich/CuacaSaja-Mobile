import 'package:flutter/material.dart';
import '/views/started.dart';
import '/services/location_service.dart';
import '/repositories/location_repository.dart';
import '/views/weather_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final LocationService _locationService =
      LocationService(LocationRepository());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _locationService.checkData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data == true) {
            return FutureBuilder<String>(
              future: _locationService.getCodeFirst(),
              builder: (context, codeSnapshot) {
                if (codeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (codeSnapshot.hasError) {
                  return Center(child: Text('Error: ${codeSnapshot.error}'));
                } else if (codeSnapshot.hasData) {
                  String firstLocationCode = codeSnapshot.data!;
                  return WeatherScreen(kode: firstLocationCode);
                }
                return const Center(child: Text('Tidak ada kode lokasi tersedia.'));
              },
            );
          } else {
            return Started();
          }
        },
      ),
    );
  }
}
