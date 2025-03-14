class UVIData {
  final double uv;
  final String uvTime;

  UVIData({required this.uv, required this.uvTime});

  factory UVIData.fromJson(Map<String, dynamic> json) {
    var res = json['result'];
    if (res == null) {
      throw Exception('Failed to load UVI data');
    }
    return UVIData(
      uv: res['uv'],
      uvTime: res['uv_time'],
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
    );
  }
}