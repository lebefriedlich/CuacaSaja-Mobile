import '/repositories/wilayah_repository.dart';
import '/models/wilayah_model.dart';

class WilayahService {
  final WilayahRepository apiRepo;

  WilayahService(this.apiRepo);

  Future<List<Provinsi>> getProvinsi() {
    return apiRepo.fetchProvinsi();
  }

  Future<List<Kabupaten>> getKabupaten(String kodeProvinsi) {
    return apiRepo.fetchKabupaten(kodeProvinsi);
  }

  Future<List<Kecamatan>> getKecamatan(String kodeKabupaten) {
    return apiRepo.fetchKecamatan(kodeKabupaten);
  }

  Future<List<Desa>> getDesa(String kodeKecamatan) {
    return apiRepo.fetchDesa(kodeKecamatan);
  }
}
