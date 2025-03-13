
class UVITime {
  final String time;
  final double uvi;

  UVITime({required this.time, required this.uvi});

  factory UVITime.fromJson(Map<String, dynamic> json) {
    return UVITime(
      time: json['time'] as String,
      uvi: json['uvi'] as double,
    );
  }
}

class UVIData {
  final double latitude;
  final double longitude;
  final UVITime now;
  final List<UVITime> forecast;
  final List<UVITime> history;

  UVIData({required this.latitude, required this.longitude, required this.now, required this.forecast, required this.history});

  factory UVIData.fromJson(Map<String, dynamic> json) {
    return UVIData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      now: UVITime.fromJson(json['now']),
      forecast: (json['forecast'] as List)
          .map((item) => UVITime.fromJson(item))
          .toList(),
      history: (json['history'] as List)
          .map((item) => UVITime.fromJson(item))
          .toList(),
    );
  }
}