class UVIData {
  final double uv;
  final String uvTime;
  final double uv_futrue_one;
  final String uvTime_future_one;

  // TODO: get next 24 hour UVI forecast
  // final List<Map<String, dynamic>> forecast;

  UVIData({
    required this.uv,
    required this.uvTime,
    required this.uv_futrue_one,
    required this.uvTime_future_one,
    // required this.forecast
  });

  factory UVIData.fromJson(Map<String, dynamic> json) {
    var res = json['result'];
    if (res == null) {
      throw Exception('Failed to load UVI data');
    }
    return UVIData(
      uv: res['uv'],
      uvTime: res['uv_time'],
      uv_futrue_one: res['uv_futrue_one'],
      uvTime_future_one: res['uvTime_future_one'],
      // forecast:
    );
  }

  factory UVIData.fromCurrentUVAPIJson(Map<String, dynamic> json) {
    var res = json['now'];
    var res1 = json['forecast'];
    if (res == null) {
      throw Exception('Failed to load UVI data');
    }
    return UVIData(
      uv: res['uvi'],
      uvTime: res['time'],
      uv_futrue_one: res1[0]['uvi'],
      uvTime_future_one: res1[0]['time'],
      // forecast:
    );
  }
}
