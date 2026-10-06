import '../../data/database/app_database.dart';

abstract class BodyRepository {
  Stream<List<BodyMeasurementEntry>> watchBodyMeasurements();
  Future<List<BodyMeasurementEntry>> getBodyMeasurements();
  Future<BodyMeasurementEntry?> getLatestBodyMeasurement();
  Future<int> addBodyMeasurement({
    required DateTime date,
    required double bodyWeight,
    double? bodyFat,
    double? chest,
    double? waist,
    double? arm,
    double? thigh,
    String? notes,
  });
  Future<int> deleteBodyMeasurement(int id);
}
