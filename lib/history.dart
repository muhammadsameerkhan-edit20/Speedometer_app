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

class HistoryScreen extends StatelessWidget {
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  String _formatDate(DateTime dt) {
    // Example: Aug 05, 2025
    return "${_monthName(dt.month)} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}";
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
        title: Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Select", style: TextStyle(color: Colors.white)),
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
          future: DatabaseHelper().getRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return Center(child: Text("No history found.", style: TextStyle(color: Colors.white)));

            final records = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                final date = r.timestamp is DateTime
                    ? r.timestamp
                    : DateTime.tryParse(r.timestamp.toString()) ?? DateTime.now();
                return Container(
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
                            CircleAvatar(
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
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // Start
                        //     Row(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Column(
                        //           children: [
                        //             Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                        //             Container(
                        //               width: 2,
                        //               height: 24,
                        //               color: Colors.white24,
                        //             ),
                        //           ],
                        //         ),
                        //         SizedBox(width: 8),
                        //         Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Text("Start", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        //                 SizedBox(width: 8),
                        //                 Text(
                        //                   r.startTime ?? "--:--",
                        //                   style: TextStyle(color: Colors.white70),
                        //                 ),
                        //               ],
                        //             ),

                        //             SizedBox(height: 2),
                        //             Text(
                        //               r.startAddress ?? "",
                        //               style: TextStyle(color: Colors.white),
                        //             ),
                        //           ],


                        //         ),
                        //       ],
                        //     ),


                        //     SizedBox(height: 8),
                        //     // Stop
                        //     Row(

                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [


                        //           children: [
                        //             Icon(Icons.fiber_manual_record, color: Colors.green, size: 16),

                        //           ],
                        //         ),
                        //         SizedBox(width: 8),
                        //         Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Text("Stop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        //                 SizedBox(width: 8),
                        //                 Text(
                        //                   r.stopTime ?? "--:--",
                        //                   style: TextStyle(color: Colors.white70),
                        //                 ),
                        //               ],
                        //             ),
                        //             SizedBox(height: 2),
                        //             Text(
                        //               r.stopAddress ?? "",
                        //               style: TextStyle(color: Colors.white),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}