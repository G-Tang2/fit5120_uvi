
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
  final double lat;
  final double long;
  final UVITime now;
  final List<UVITime> forecast;
  final List<UVITime> history;

  UVIData({required this.lat, required this.long, required this.now, required this.forecast, required this.history});

  factory UVIData.fromJson(Map<String, dynamic> json) {
    return UVIData(
      lat: json['lat'] as double,
      long: json['long'] as double,
      now: UVITime.fromJson(json['now']),
      forecast: json['forecast'].map((e) => UVITime.fromJson(e)).toList(),
      history: json['history'].map((e) => UVITime.fromJson(e)).toList(),
    );
  }
}