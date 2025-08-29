// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'Database/database_helper.dart';
// import 'Model/tracking_history.dart';
//
// class HistoryScreen extends StatelessWidget {
//   String _formatDuration(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Tracking History')),
//       body: FutureBuilder<List<TrackingRecord>>(
//         future: DatabaseHelper().getRecords(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState != ConnectionState.done)
//             return Center(child: CircularProgressIndicator());
//           if (!snapshot.hasData || snapshot.data!.isEmpty)
//             return Center(child: Text("No history found."));
//
//           final records = snapshot.data!;
//           return ListView.builder(
//             itemCount: records.length,
//             itemBuilder: (context, index) {
//               final r = records[index];
//               return ListTile(
//                 title: Text(
//                   'Distance: ${r.distance.toStringAsFixed(2)} km, Avg: ${r.averageSpeed.toStringAsFixed(1)} km/h',
//                 ),
//                 subtitle: Text(
//                   'Top: ${r.topSpeed.toStringAsFixed(1)} km/h, Duration: ${_formatDuration(r.duration)} mins\n${r.timestamp}',
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'Database/database_helper.dart';
import 'Model/tracking_history.dart';
import 'history_detail.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<TrackingRecord>> _recordsFuture;
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};

  @override
  void initState() {
    super.initState();
    _recordsFuture = DatabaseHelper().getRecords();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  String _formatDate(DateTime dt) {
    // Example: Aug 05, 2025
    return "${_monthName(dt.month)} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}";
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'pm' : 'am';
    return "$hour:$minute$suffix";
  }

  String _monthName(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xff68DAE4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectionMode ? "${_selectedIds.length} Selected" : 'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_selectionMode) {
                  _selectionMode = false;
                  _selectedIds.clear();
                } else {
                  _selectionMode = true;
                }
              });
            },
            child: Text(_selectionMode ? "Cancel" : "Select", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF033438), Color(0xFF081214)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<TrackingRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return Center(child: Text("No history found.", style: TextStyle(color: Colors.white)));

            final records = snapshot.data!;
            return Stack(
              children: [
                ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                final date = r.timestamp is DateTime
                    ? r.timestamp
                    : DateTime.tryParse(r.timestamp.toString()) ?? DateTime.now();
                final bool isSelected = r.id != null && _selectedIds.contains(r.id);
                return GestureDetector(
                  onTap: () async {
                    if (_selectionMode) {
                      setState(() {
                        if (r.id != null) {
                          if (isSelected) {
                            _selectedIds.remove(r.id);
                          } else {
                            _selectedIds.add(r.id!);
                          }
                        }
                      });
                      return;
                    }
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(record: r),
                      ),
                    );
                    if (result == 'deleted') {
                      setState(() {
                        _recordsFuture = DatabaseHelper().getRecords();
                      });
                    }
                  },
                  child: Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xff68DAE4),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${r.distance.toStringAsFixed(1)}Km",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _formatDate(date),
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${r.averageSpeed.toStringAsFixed(1)}Km/h",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _formatDuration(r.duration),
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            _selectionMode
                                ? Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Color(0xff68DAE4), width: 2),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: isSelected
                                          ? Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Color(0xff68DAE4),
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.arrow_forward, color: Color(0xff68DAE4)),
                                  ),
                          ],
                        ),
                      ),
                      // Timeline Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Start row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                                    Container(width: 2, height: 24, color: Colors.white24),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Start', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                          SizedBox(width: 10),
                                          Text(_formatTime(date), style: TextStyle(color: Colors.white54)),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(r.startAddress ?? '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Stop row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Stop', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                          SizedBox(width: 10),
                                          Text(_formatTime(date.add(r.duration)), style: TextStyle(color: Colors.white54)),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(r.stopAddress ?? '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  ),
                );
              },
            ),
                if (_selectionMode)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () async {
                                      final confirmed = await showModalBottomSheet<bool>(
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
                                                  style: TextStyle(color: Colors.black54, fontSize: 14),
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
                                                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
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
                                                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      if (confirmed == true) {
                                        final ids = _selectedIds.toList();
                                        for (final id in ids) {
                                          await DatabaseHelper().deleteRecord(id);
                                        }
                                        setState(() {
                                          _selectedIds.clear();
                                          _recordsFuture = DatabaseHelper().getRecords();
                                        });
                                      }
                                    },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0x33FFFFFF)),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () async {
                                      final selected = records.where((r) => r.id != null && _selectedIds.contains(r.id)).toList();
                                      if (selected.isEmpty) return;
                                      final buffer = StringBuffer();
                                      for (final r in selected) {
                                        final date = r.timestamp is DateTime
                                            ? r.timestamp
                                            : DateTime.tryParse(r.timestamp.toString()) ?? DateTime.now();
                                        buffer
                                          ..writeln('Trip on ${_monthName(date.month)} ${date.day.toString().padLeft(2,'0')}, ${date.year}')
                                          ..writeln('Start: ${r.startAddress ?? '-'}')
                                          ..writeln('Stop: ${r.stopAddress ?? '-'}')
                                          ..writeln('Duration: ${_formatDuration(r.duration)}')
                                          ..writeln('Distance: ${r.distance.toStringAsFixed(1)} km')
                                          ..writeln('Avg: ${r.averageSpeed.toStringAsFixed(0)} km/h, Top: ${r.topSpeed.toStringAsFixed(0)} km/h')
                                          ..writeln('');
                                      }
                                      await Share.share(buffer.toString());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff68DAE4),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Share', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}