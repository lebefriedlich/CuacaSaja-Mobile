import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/location_code.dart';
import '/views/add_location_picker.dart';
import '/views/weather_screen.dart';
import '/services/location_service.dart';
import '/repositories/location_repository.dart';
import '/models/bmkg_model.dart';
import '/services/bmkg_service.dart';
import '/repositories/bmkg_repository.dart';

class AddLocation extends StatefulWidget {
  final String? kode;
  const AddLocation({super.key, this.kode});

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  late LocationService _service;
  Set<String> selectedLocations = {};
  String? lastLocationCode;

  Map<String, BMKGModel?> bmkgDataMap = {};

  @override
  void initState() {
    super.initState();
    _service = LocationService(LocationRepository());
    selectedLocations.clear();
  }

  void toggleSelection(String location) {
    setState(() {
      if (selectedLocations.contains(location)) {
        selectedLocations.remove(location);
      } else {
        selectedLocations.add(location);
      }
    });
  }

  Future<void> deleteSelected() async {
    for (var location in selectedLocations.toList()) {
      await _service.removeLocationCode(location);
    }

    final updatedLocations = await _service.getLocationCodes();

    if (updatedLocations.isNotEmpty) {
      lastLocationCode = updatedLocations.last.code;
    }

    setState(() {
      selectedLocations.clear();
      bmkgDataMap.clear();
    });
  }

  void _handleBackButton() {
    if (lastLocationCode != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return WeatherScreen(kode: lastLocationCode!);
          },
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 16),
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: _handleBackButton,
              ),
              centerTitle: true,
              title: const Text(
                'Kelola Lokasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF312E81),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(3, -0.3),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.deepPurple),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(-3, -0.3),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF673AB7)),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0, -1.2),
                  child: Container(
                    height: 300,
                    width: 600,
                    decoration: const BoxDecoration(color: Color(0xFFFFAB40)),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
                FutureBuilder<List<LocationCode>>(
                  future: _service.getLocationCodes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada lokasi tersimpan'));
                    } else {
                      List<String> locations =
                          snapshot.data!.map((loc) => loc.code).toList();

                      return ListView(
                        children: [
                          ...locations.map((location) {
                            final bmkgData = bmkgDataMap[location];
                            if (bmkgData == null) {
                              BmkgService BMKGService =
                                  BmkgService(BmkgRepository());
                              return FutureBuilder<List<BMKGModel>>(
                                future: BMKGService.fetchBMKG(location),
                                builder: (context, bmkgSnapshot) {
                                  if (bmkgSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (bmkgSnapshot.hasError) {
                                    return Text('Error: ${bmkgSnapshot.error}');
                                  } else if (!bmkgSnapshot.hasData ||
                                      bmkgSnapshot.data!.isEmpty) {
                                    return const Text(
                                        'Data BMKG tidak tersedia');
                                  } else {
                                    final bmkgData = bmkgSnapshot.data!.first;
                                    bmkgDataMap[location] =
                                        bmkgData;
                                    return _buildLocationCard(
                                        locations, location, bmkgData);
                                  }
                                },
                              );
                            } else {
                              return _buildLocationCard(locations, location,
                                  bmkgData);
                            }
                          }),
                          if (selectedLocations.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: deleteSelected,
                                child: const Text('Hapus Terpilih'),
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FutureBuilder<bool>(
          future: _service.checkData5(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else if (snapshot.hasError) {
              return const SizedBox.shrink();
            } else if (snapshot.hasData && snapshot.data == true) {
              return ClipOval(
                child: Material(
                  color: Colors.blueAccent,
                  child: InkWell(
                    splashColor: Colors.white,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 36,
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddLocationPicker(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLocationCard(
      List<String> locations, String location, BMKGModel bmkgData) {
    return GestureDetector(
      onLongPress: locations.length > 1
          ? () {
              if (selectedLocations.contains(location)) {
                toggleSelection(location);
              } else if (selectedLocations.length < locations.length - 1) {
                toggleSelection(location);
              }
            }
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(kode: location),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF4C47A3),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            bmkgData.village,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            bmkgData.weatherDescription,
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: Text(
            "${bmkgData.temperature.toStringAsFixed(0)}°C",
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: selectedLocations.contains(location)
              ? const Icon(Icons.check, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
