import '/models/location_code.dart';
import '/repositories/location_repository.dart';

class LocationService {
  final LocationRepository _repository;

  LocationService(this._repository);

  Future<String> addLocationCode(String code) async {
    return await _repository.addLocationCode(code);
  }

  Future<bool> removeLocationCode(String code) async {
    return await _repository.removeLocationCode(code);
  }

  Future<List<LocationCode>> getLocationCodes() async {
    return await _repository.locationCodes;
  }

  Future<bool> checkData5() async {
    return await _repository.checkData5();
  }

  Future<bool> checkData() async {
    return await _repository.checkData();
  }

  Future<String> getCodeFirst() async {
    return await _repository.getCodeFirst();
  }
}
