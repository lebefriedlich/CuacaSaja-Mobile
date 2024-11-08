import '/repositories/bmkg_repository.dart';
import '/models/bmkg_model.dart';

class BmkgService {
  final BmkgRepository apiRepo;

  BmkgService(this.apiRepo);

  Future<List<BMKGModel>> fetchBMKG(String kode) {
    return apiRepo.fetchBMKG(kode);
  }
}
