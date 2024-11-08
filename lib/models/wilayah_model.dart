class Provinsi {
  final String kodeProvinsi;
  final String nama;

  Provinsi({required this.kodeProvinsi, required this.nama});

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      kodeProvinsi: json['kode'].toString(),
      nama: json['nama'].toString(),
    );
  }
}

class Kabupaten {
  final String kodeKabupaten;
  final String nama;

  Kabupaten({required this.kodeKabupaten, required this.nama});

  factory Kabupaten.fromJson(Map<String, dynamic> json) {
    return Kabupaten(
      kodeKabupaten: json['kode'].toString(),
      nama: json['nama'].toString(),
    );
  }
}

class Kecamatan {
  final String kodeKecamatan;
  final String nama;

  Kecamatan({required this.kodeKecamatan, required this.nama});

  factory Kecamatan.fromJson(Map<String, dynamic> json) {
    return Kecamatan(
      kodeKecamatan: json['kode'].toString(),
      nama: json['nama'].toString(),
    );
  }
}

class Desa {
  final String kodeDesa;
  final String nama;

  Desa({required this.kodeDesa, required this.nama});

  factory Desa.fromJson(Map<String, dynamic> json) {
    return Desa(
      kodeDesa: json['kode'].toString(),
      nama: json['nama'].toString(),
    );
  }
}
