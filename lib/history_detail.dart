import 'package:flutter/material.dart';
import 'Model/tracking_history.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Database/database_helper.dart';
import 'package:share_plus/share_plus.dart';

class HistoryDetailScreen extends StatelessWidget {
  final TrackingRecord record;
  const HistoryDetailScreen({Key? key, required this.record}) : super(key: key);

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  String _formatDate(DateTime dt) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return "${months[dt.month-1]} ${dt.day.toString().padLeft(2,'0')}, ${dt.year}";
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'pm' : 'am';
    return "$h:$m$suffix";
  }

  @override
  Widget build(BuildContext context) {
    final stopTs = record.stopTimestamp ?? record.timestamp.add(record.duration);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xff68DAE4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF033438), Color(0xFF081214)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: (record.startLat != null && record.startLng != null)
                      ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(record.startLat!, record.startLng!),
                            zoom: 14,
                          ),
                          markers: {
                            if (record.startLat != null && record.startLng != null)
                              Marker(markerId: const MarkerId('start'), position: LatLng(record.startLat!, record.startLng!), infoWindow: const InfoWindow(title: 'Start')),
                            if (record.stopLat != null && record.stopLng != null)
                              Marker(markerId: const MarkerId('stop'), position: LatLng(record.stopLat!, record.stopLng!), infoWindow: const InfoWindow(title: 'Stop')),
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        )
                      : Container(
                          color: Colors.white24,
                          child: const Center(
                            child: Text('Map Preview', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(record.timestamp),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Timeline
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: const [
                          Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                          SizedBox(height: 24, child: VerticalDivider(color: Colors.white24, width: 2)),
                        ]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text('Start', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 10),
                                Text(_formatTime(record.timestamp), style: const TextStyle(color: Colors.white54)),
                              ]),
                              const SizedBox(height: 4),
                              Text(
                                record.startAddress ?? '-',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text('Stop', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 10),
                                Text(_formatTime(stopTs), style: const TextStyle(color: Colors.white54)),
                              ]),
                              const SizedBox(height: 4),
                              Text(
                                record.stopAddress ?? '-',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statTile('Duration', _formatDuration(record.duration)),
                  _divider(),
                  _statTile('Distance', '${record.distance.toStringAsFixed(1)} km'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statTile('Avg Speed', '${record.averageSpeed.toStringAsFixed(0)} km/h'),
                  _divider(),
                  _statTile('Top Speed', '${record.topSpeed.toStringAsFixed(0)} km/h'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showModalBottomSheet<bool>(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (ctx) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delete record',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Are you really want to delete this record?',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0x33000000)),
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xff68DAE4),
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (confirm == true && record.id != null) {
                          await DatabaseHelper().deleteRecord(record.id!);
                          Navigator.pop(context, 'deleted');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff363636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = StringBuffer()
                          ..writeln('Trip on ${_formatDate(record.timestamp)}')
                          ..writeln('Start: ${record.startAddress ?? '-'}')
                          ..writeln('Stop: ${record.stopAddress ?? '-'}')
                          ..writeln('Duration: ${_formatDuration(record.duration)}')
                          ..writeln('Distance: ${record.distance.toStringAsFixed(1)} km')
                          ..writeln('Avg: ${record.averageSpeed.toStringAsFixed(0)} km/h, Top: ${record.topSpeed.toStringAsFixed(0)} km/h');
                        await Share.share(text.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff68DAE4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() => const SizedBox(
        width: 1,
        height: 40,
        child: DecoratedBox(decoration: BoxDecoration(color: Colors.white24)),
      );
}


