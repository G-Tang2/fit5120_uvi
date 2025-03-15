class UVIData {
  final double uv;
  final String uvTime;
  final double uv_max;

  UVIData({required this.uv, required this.uvTime, required this.uv_max});

  factory UVIData.fromJson(Map<String, dynamic> json) {
    var res = json['result'];
    if (res == null) {
      throw Exception('Failed to load UVI data');
    }
    return UVIData(
      uv: res['uv'],
      uvTime: res['uv_time'],
      uv_max: res['uv_max'],
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
    );
  }
}