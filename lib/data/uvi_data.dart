class UVIData {
  final double uv;
  final String uvTime;
  // TODO: get next 24 hour UVI forecast
  // final List<Map<String, dynamic>> forecast;

  UVIData({required this.uv, 
  required this.uvTime,
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
      // forecast:
    );
  }

  factory UVIData.fromCurrentUVAPIJson(Map<String, dynamic> json) {
      var res = json['now'];
      if (res == null) {
        throw Exception('Failed to load UVI data');
      }
      return UVIData(
        uv: res['uvi'],
        uvTime: res['time'],
        // forecast:
    );
  }
}