import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';
@JsonSerializable()
class LocationModel {
  String? lon;
  String? lat;

  LocationModel(this.lon, this.lat);

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
