class TrackingRecord {
  final int? id;
  final double distance;
  final double averageSpeed;
  final double topSpeed;
  final Duration duration;
  final DateTime timestamp;

  TrackingRecord({
    this.id,
    required this.distance,
    required this.averageSpeed,
    required this.topSpeed,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'distance': distance,
    'averageSpeed': averageSpeed,
    'topSpeed': topSpeed,
    'duration': duration.inSeconds,
    'timestamp': timestamp.toIso8601String(),
  };

  static TrackingRecord fromMap(Map<String, dynamic> map) => TrackingRecord(
    id: map['id'],
    distance: map['distance'],
    averageSpeed: map['averageSpeed'],
    topSpeed: map['topSpeed'],
    duration: Duration(seconds: map['duration']),
    timestamp: DateTime.parse(map['timestamp']),
  );
}
