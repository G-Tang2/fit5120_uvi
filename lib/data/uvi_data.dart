class UVIData {
  final double uv;
  final String uvTime;
  final double uv_max;
  final String uv_maxTime;

  UVIData({required this.uv, required this.uvTime, required this.uv_max, required this.uv_maxTime});

  factory UVIData.fromJson(Map<String, dynamic> json) {
    var res = json['result'];
    if (res == null) {
      throw Exception('Failed to load UVI data');
    }
    return UVIData(
      uv: res['uv'],
      uvTime: res['uv_time'],
      uv_max: res['uv_max'],
      uv_maxTime: res['uv_max_time'],
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
        uv_max: res['uv_max'] ?? 0.0,
        uv_maxTime: res['uv_max_time']?? "",
    );
  }
}