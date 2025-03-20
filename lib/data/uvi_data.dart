class UVIData {
  final double uv;
  final String uvTime;
  final bool ok;
  final List<Map<String, dynamic>>? forecast;
  final String? message;
  final double uv_futrue_one; // Assuming this field comes from 'forecast'
  final String uvTime_future_one;

  UVIData({
    required this.uv,
    required this.uvTime,
    required this.uv_futrue_one,
    required this.uvTime_future_one,
    required this.ok,
    this.forecast,
    this.message,
  });

  // Factory for parsing UVI data with forecast
  factory UVIData.fromJson(Map<String, dynamic> json) {
    if (json['ok'] == true && json.containsKey('forecast')) {
      var forecast = List<Map<String, dynamic>>.from(json['forecast']);
      return UVIData(
        uv: json['now']['uvi'],
        uvTime: json['now']['time'],
        uv_futrue_one: forecast.isNotEmpty ? forecast[0]['uvi'] : 0.0, // Default to 0.0 if no forecast
        uvTime_future_one: forecast.isNotEmpty ? forecast[0]['time'] : '',
        forecast: forecast,
        ok: true,
        message: null,
      );
    } else {
      return UVIData(
        uv: 0.0, // Default value for UV if missing
        uvTime: "",
        uv_futrue_one: 0.0, // Default value if no forecast available
        uvTime_future_one: "",
        ok: false,
        forecast: null,
        message: json['message'] ?? 'Failed to load UVI data',
      );
    }
  }

  // Factory for parsing only current UVI data without forecast
  factory UVIData.fromCurrentUVAPIJson(Map<String, dynamic> json) {
    var res = json['now'];
    var res1 = json['forecast'];
    if (res == null) {
      throw Exception('Failed to load current UVI data');
    }

    return UVIData(
      uv: res['uvi'],
      uvTime: res['time'],
      uv_futrue_one: res1.isNotEmpty ? res1[0]['uvi'] : 0.0, // Default to 0.0 if no forecast
      uvTime_future_one: res1.isNotEmpty ? res1[0]['time'] : '',
      forecast: res1.isNotEmpty
          ? List<Map<String, dynamic>>.from(res1)
          : null, // Include forecast if available
      ok: true,
      message: null,
    );
  }
}
