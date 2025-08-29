class TrackingRecord {
  final int? id;
  final double distance;
  final double averageSpeed;
  final double topSpeed;
  final Duration duration;
  final DateTime timestamp; // start timestamp

  // Optional mapping fields
  final String? startAddress;
  final String? stopAddress;
  final DateTime? stopTimestamp;
  final double? startLat;
  final double? startLng;
  final double? stopLat;
  final double? stopLng;

  TrackingRecord({
    this.id,
    required this.distance,
    required this.averageSpeed,
    required this.topSpeed,
    required this.duration,
    required this.timestamp,
    this.startAddress,
    this.stopAddress,
    this.stopTimestamp,
    this.startLat,
    this.startLng,
    this.stopLat,
    this.stopLng,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'distance': distance,
    'averageSpeed': averageSpeed,
    'topSpeed': topSpeed,
    'duration': duration.inSeconds,
    'timestamp': timestamp.toIso8601String(),
    'startAddress': startAddress,
    'stopAddress': stopAddress,
    'stopTimestamp': stopTimestamp?.toIso8601String(),
    'startLat': startLat,
    'startLng': startLng,
    'stopLat': stopLat,
    'stopLng': stopLng,
  };

  static TrackingRecord fromMap(Map<String, dynamic> map) => TrackingRecord(
    id: map['id'],
    distance: (map['distance'] as num).toDouble(),
    averageSpeed: (map['averageSpeed'] as num).toDouble(),
    topSpeed: (map['topSpeed'] as num).toDouble(),
    duration: Duration(seconds: map['duration'] as int),
    timestamp: DateTime.parse(map['timestamp'] as String),
    startAddress: map['startAddress'] as String?,
    stopAddress: map['stopAddress'] as String?,
    stopTimestamp: map['stopTimestamp'] != null ? DateTime.parse(map['stopTimestamp'] as String) : null,
    startLat: (map['startLat'] as num?)?.toDouble(),
    startLng: (map['startLng'] as num?)?.toDouble(),
    stopLat: (map['stopLat'] as num?)?.toDouble(),
    stopLng: (map['stopLng'] as num?)?.toDouble(),
  );
}
