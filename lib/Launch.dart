import 'package:spacexapp/Links.dart';

class Launch {
  final int flight_number;
  final String mission_name;
  final String details;
  final Links links;

  Launch({this.flight_number, this.mission_name, this.details, this.links});

  factory Launch.fromJson(Map<String, dynamic> json) {
    return Launch(
      flight_number: json['flight_number'],
      mission_name: json['mission_name'],
      details: json['details'],
      links: Links.fromJson(json['links']),
    );
  }
}
