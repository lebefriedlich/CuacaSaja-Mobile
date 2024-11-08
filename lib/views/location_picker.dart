import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/views/weather_screen.dart';
import '/services/wilayah_service.dart';
import '/models/wilayah_model.dart';
import '/repositories/wilayah_repository.dart';
import '/services/location_service.dart';
import '/repositories/location_repository.dart';

class LocationDropdown extends StatefulWidget {
  const LocationDropdown({super.key});

  @override
  _LocationDropdownState createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  String? selectedProvince;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedVillage;
  String? selectedCode;

  List<Provinsi> provinces = [];
  List<Kabupaten> cities = [];
  List<Kecamatan> districts = [];
  List<Desa> villages = [];

  bool isLoading = true;

  final WilayahRepository _wilayahRepository = WilayahRepository();
  late final WilayahService _wilayahService;
  final LocationService _service;

  _LocationDropdownState() : _service = LocationService(LocationRepository());

  @override
  void initState() {
    super.initState();
    _wilayahService = WilayahService(_wilayahRepository);
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      List<Provinsi> fetchedProvinces = await _wilayahService.getProvinsi();
      setState(() {
        provinces = fetchedProvinces;
        isLoading = false;
      });
    } catch (error) {
      print('Failed to load provinces: $error');
    }
  }

  Future<void> _fetchCities(String kodeProvinsi) async {
    try {
      List<Kabupaten> fetchedCities =
          await _wilayahService.getKabupaten(kodeProvinsi);
      setState(() {
        cities = fetchedCities;
        selectedCity = null;
        selectedDistrict = null;
        selectedVillage = null;
      });
    } catch (error) {
      print('Failed to load cities: $error');
    }
  }

  Future<void> _fetchDistricts(String kodeKabupaten) async {
    try {
      List<Kecamatan> fetchedDistricts =
          await _wilayahService.getKecamatan(kodeKabupaten);
      setState(() {
        districts = fetchedDistricts;
        selectedDistrict = null;
        selectedVillage = null;
      });
    } catch (error) {
      print('Failed to load districts: $error');
    }
  }

  Future<void> _fetchVillages(String kodeKecamatan) async {
    try {
      List<Desa> fetchedVillages = await _wilayahService.getDesa(kodeKecamatan);
      setState(() {
        villages = fetchedVillages;
        selectedVillage = null;
      });
    } catch (error) {
      print('Failed to load villages: $error');
    }
  }

  Future<void> _addLocation() async {
    if (selectedCode != null && selectedCode!.isNotEmpty) {
      if (await _service.addLocationCode(selectedCode!) ==
          "Lokasi Berhasil Ditambahkan") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(kode: selectedCode!),
          ),
        );
      } else if (await _service.addLocationCode(selectedCode!) ==
          "Lokasi Sudah Ada") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi sudah disimpan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal 5 lokasi sudah disimpan.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode tidak valid.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 16),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
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
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Masukkan Lokasi Baru",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildDropdown(
                          hint: 'Pilih Provinsi',
                          value: selectedProvince,
                          items: provinces
                              .map((provinsi) => provinsi.nama)
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProvince = value;
                              _fetchCities(provinces
                                  .firstWhere(
                                      (provinsi) => provinsi.nama == value)
                                  .kodeProvinsi);
                            });
                          },
                        ),
                        if (selectedProvince != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdown(
                            hint: 'Pilih Kota/Kabupaten',
                            value: selectedCity,
                            items: cities.map((city) => city.nama).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                                _fetchDistricts(cities
                                    .firstWhere((city) => city.nama == value)
                                    .kodeKabupaten);
                              });
                            },
                          ),
                        ],
                        if (selectedCity != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdown(
                            hint: 'Pilih Kecamatan',
                            value: selectedDistrict,
                            items: districts
                                .map((district) => district.nama)
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDistrict = value;
                                _fetchVillages(districts
                                    .firstWhere(
                                        (district) => district.nama == value)
                                    .kodeKecamatan);
                              });
                            },
                          ),
                        ],
                        if (selectedDistrict != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdown(
                            hint: 'Pilih Desa/Kelurahan',
                            value: selectedVillage,
                            items: villages
                                .map((village) => village.nama)
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedVillage = value;
                                selectedCode = villages
                                    .firstWhere(
                                        (village) => village.nama == value)
                                    .kodeDesa;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          if (selectedVillage != null) ...[
                            ElevatedButton(
                              onPressed: () {
                                _addLocation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Tambah Lokasi Baru',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0),
            child: Text(
              hint,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 10.0),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            );
          }).toList(),
          dropdownColor: const Color.fromARGB(200, 68, 137, 255),
          borderRadius: BorderRadius.circular(20),
          onChanged: onChanged,
          isExpanded: false,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
        ),
      ),
    );
  }
}
