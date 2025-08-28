import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedo_meter/history.dart';

import '../Database/database_helper.dart';
import '../gauge_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void showRateUsDialog(BuildContext context) {
    int selectedRating = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            height: 230,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // 👍 Icon in a bubble
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enjoying the app? Let us know!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Mulish',
                  ),
                ),
                const SizedBox(height: 16),

                // ⭐ Star Rating
                StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 35,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // handle rating logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Thanks for rating us $selectedRating stars!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Rate",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          //  color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        height: 40,
                        width: 70,
                        child: Center(
                          child: Text(
                            "Later",
                            style: TextStyle(
                              color: Color(0xff7A7A7A),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<bool> showDailyGoalDialog(
  //     BuildContext context,
  //     int initialValue,
  //     ) async {
  //   int currentValue = initialValue;
  //   bool isSaved = false;
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Color(0xffE4E4E4),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Daily Goal",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mulish'),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Row(
  //               mainAxisSize: MainAxisSize.min,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 NumberPicker(
  //                   value: currentValue,
  //                   minValue: 100,
  //                   decoration: BoxDecoration(),
  //                   maxValue: 10000,
  //                   step: 50,
  //                   haptics: true,
  //                   onChanged: (value) => setState(() => currentValue = value),
  //                   selectedTextStyle: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.blue,
  //                     fontSize: 28,
  //                   ),
  //                   textStyle: TextStyle(color: Colors.grey, fontSize: 20),
  //                 ),
  //                 Text(
  //                   "ml",
  //
  //                   style: TextStyle(
  //                     fontSize: 30,
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xff278DE8),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               InkWell(
  //                 onTap: () async {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.blue),
  //                     //  color: Colors.blue,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //
  //                   height: 40,
  //                   width: 70,
  //                   child: Center(
  //                     child: Text(
  //                       "CANCEL",
  //                       style: TextStyle(
  //                         color: Color(0xff7A7A7A),
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Mulish',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   await DatabaseHelper.instance.updateDailyGoal(currentValue);
  //                   await DatabaseHelper.instance.debugPrintAllUserData();
  //                   Navigator.of(context).pop();
  //                   isSaved = true;
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("Daily goal set to $currentValue ml"),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blue,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: Text("Save", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   return isSaved;
  // }
  //
  // void showWeightDialog(BuildContext context, int initialValue) {
  //   int weightValue = initialValue;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Weight",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mulish'),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 NumberPicker(
  //                   value: weightValue,
  //                   minValue: 10,
  //                   maxValue: 120,
  //                   step: 1,
  //                   haptics: true,
  //                   onChanged: (value) => setState(() => weightValue = value),
  //                   selectedTextStyle: TextStyle(
  //                     color: Colors.blue,
  //                     fontSize: 28,
  //                   ),
  //                   textStyle: TextStyle(color: Colors.grey, fontSize: 20),
  //                 ),
  //                 Text(
  //                   "kg",
  //                   style: TextStyle(
  //                     fontSize: 26,
  //                     color: Colors.blue,
  //                     fontWeight: FontWeight.bold,
  //                     fontFamily: 'Mulish',
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               InkWell(
  //                 onTap: () async {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.blue),
  //                     //  color: Colors.blue,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //
  //                   height: 40,
  //                   width: 70,
  //                   child: Center(
  //                     child: Text(
  //                       "CANCEL",
  //                       style: TextStyle(
  //                         color: Color(0xff7A7A7A),
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Mulish',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   await DatabaseHelper.instance.updateWeight(weightValue);
  //                   await DatabaseHelper.instance.debugPrintAllUserData();
  //                   Navigator.of(context).pop();
  //
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text("Weight set to $weightValue Kl")),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blue,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: Text("Save", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void showWakeUpTimeDialog(BuildContext context, TimeOfDay initialTime) {
  //   int selectedHour = initialTime.hour;
  //   int selectedMinute = initialTime.minute;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Wake Up Time",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mulish'),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text("Hour", style: TextStyle(color: Colors.grey)),
  //                     NumberPicker(
  //                       value: selectedHour,
  //                       minValue: 0,
  //                       maxValue: 23,
  //                       zeroPad: true,
  //                       onChanged: (value) =>
  //                           setState(() => selectedHour = value),
  //                       selectedTextStyle: TextStyle(
  //                         color: Colors.blue,
  //                         fontSize: 24,
  //                       ),
  //                       textStyle: TextStyle(color: Colors.grey, fontSize: 18),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(width: 16),
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text("Minute", style: TextStyle(color: Colors.grey)),
  //                     NumberPicker(
  //                       value: selectedMinute,
  //                       minValue: 0,
  //                       maxValue: 59,
  //                       zeroPad: true,
  //                       onChanged: (value) =>
  //                           setState(() => selectedMinute = value),
  //                       selectedTextStyle: TextStyle(
  //                         color: Colors.blue,
  //                         fontSize: 24,
  //                       ),
  //                       textStyle: TextStyle(color: Colors.grey, fontSize: 18),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.blue),
  //                     //  color: Colors.blue,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //
  //                   height: 40,
  //                   width: 70,
  //                   child: Center(
  //                     child: Text(
  //                       "CANCEL",
  //                       style: TextStyle(
  //                         color: Color(0xff7A7A7A),
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Mulish',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   final newTime = TimeOfDay(
  //                     hour: selectedHour,
  //                     minute: selectedMinute,
  //                   );
  //                   final formatted =
  //                       "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
  //
  //                   await DatabaseHelper.instance.updateWakeUpTime(formatted);
  //                   await DatabaseHelper.instance.debugPrintAllUserData();
  //
  //                   Navigator.of(context).pop();
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text(
  //                         "Wake-up time set to ${newTime.format(context)}",
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blue,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: Text("Save", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void showsleepTimeDialog(BuildContext context, TimeOfDay initialTime) {
  //   int selectedHour = initialTime.hour;
  //   int selectedMinute = initialTime.minute;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "sleepTime",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mulish'),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text("Hour", style: TextStyle(color: Colors.grey)),
  //                     NumberPicker(
  //                       value: selectedHour,
  //                       minValue: 0,
  //                       maxValue: 23,
  //                       zeroPad: true,
  //                       onChanged: (value) =>
  //                           setState(() => selectedHour = value),
  //                       selectedTextStyle: TextStyle(
  //                         color: Colors.blue,
  //                         fontSize: 24,
  //                       ),
  //                       textStyle: TextStyle(color: Colors.grey, fontSize: 18),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(width: 16),
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text("Minute", style: TextStyle(color: Colors.grey)),
  //                     NumberPicker(
  //                       value: selectedMinute,
  //                       minValue: 0,
  //                       maxValue: 59,
  //                       zeroPad: true,
  //                       onChanged: (value) =>
  //                           setState(() => selectedMinute = value),
  //                       selectedTextStyle: TextStyle(
  //                         color: Colors.blue,
  //                         fontSize: 24,
  //                       ),
  //                       textStyle: TextStyle(color: Colors.grey, fontSize: 18),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.blue),
  //                     //  color: Colors.blue,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //
  //                   height: 40,
  //                   width: 70,
  //                   child: Center(
  //                     child: Text(
  //                       "CANCEL",
  //                       style: TextStyle(
  //                         color: Color(0xff7A7A7A),
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Mulish',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   final newTime = TimeOfDay(
  //                     hour: selectedHour,
  //                     minute: selectedMinute,
  //                   );
  //                   final formatted =
  //                       "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
  //
  //                   await DatabaseHelper.instance.updateSleepTime(formatted);
  //                   await DatabaseHelper.instance.debugPrintAllUserData();
  //
  //                   Navigator.of(context).pop();
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text(
  //                         "sleepTime set to ${newTime.format(context)}",
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blue,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: Text("Save", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void showGenderDialog(BuildContext context, String initialGender) {
  //   String selectedGender = initialGender;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Select Gender",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mulish'),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 RadioListTile<String>(
  //                   activeColor: Colors.blue,
  //                   title: Text("Male"),
  //                   value: "Male",
  //                   groupValue: selectedGender,
  //                   onChanged: (value) =>
  //                       setState(() => selectedGender = value!),
  //                 ),
  //                 RadioListTile<String>(
  //                   title: Text("Female"),
  //                   activeColor: Colors.blue,
  //
  //                   value: "Female",
  //                   groupValue: selectedGender,
  //                   onChanged: (value) =>
  //                       setState(() => selectedGender = value!),
  //                 ),
  //                 RadioListTile<String>(
  //                   title: Text("Other"),
  //                   activeColor: Colors.blue,
  //
  //                   value: "Other",
  //                   groupValue: selectedGender,
  //                   onChanged: (value) =>
  //                       setState(() => selectedGender = value!),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               InkWell(
  //                 onTap: () async {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.blue),
  //                     //  color: Colors.blue,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //
  //                   height: 40,
  //                   width: 70,
  //                   child: Center(
  //                     child: Text(
  //                       "CANCEL",
  //                       style: TextStyle(
  //                         color: Color(0xff7A7A7A),
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Mulish',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   await DatabaseHelper.instance.updateGender(selectedGender);
  //                   await DatabaseHelper.instance.debugPrintAllUserData();
  //                   Navigator.of(context).pop();
  //
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text("Gender set to $selectedGender")),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blue,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: Text("Save", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // String selectedSound = "Chime";
  //
  // final AudioPlayer _player =
  // AudioPlayer(); // declare once (globally or inside your class)
  //
  // void _showSoundPicker(BuildContext context) {
  //   List<String> sounds = ["Chime", "Bell", "Beep", "Drop"];
  //   String tempSelectedSound = selectedSound;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           return AlertDialog(
  //             backgroundColor: Colors.white,
  //             title: Text(
  //               "Notification sound",
  //               style: TextStyle(fontFamily: 'Mulish'),
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: sounds.map((sound) {
  //                 return RadioListTile<String>(
  //                   activeColor: Colors.blue,
  //                   title: Text(sound),
  //                   value: sound,
  //                   groupValue: tempSelectedSound,
  //                   onChanged: (value) async {
  //                     setDialogState(() {
  //                       tempSelectedSound = value!;
  //                     });
  //
  //                     // Play the selected sound
  //                     try {
  //                       await _player
  //                           .stop(); // stop if a previous sound is playing
  //                       await _player.play(
  //                         AssetSource('sounds/${value!.toLowerCase()}.mp3'),
  //                       );
  //                     } catch (e) {
  //                       print('Error playing sound: $e');
  //                     }
  //                   },
  //                 );
  //               }).toList(),
  //             ),
  //             actions: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         border: Border.all(color: Colors.blue),
  //                         //  color: Colors.blue,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //
  //                       height: 40,
  //                       width: 70,
  //                       child: Center(
  //                         child: Text(
  //                           "CANCEL",
  //                           style: TextStyle(
  //                             color: Color(0xff7A7A7A),
  //                             fontWeight: FontWeight.bold,
  //                             fontFamily: 'Mulish',
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () async {
  //                       await _player.stop();
  //                       Navigator.pop(
  //                         context,
  //                         tempSelectedSound,
  //                       ); // return selected sound
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blue,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       "Save",
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ).then((selected) async {
  //     if (selected != null) {
  //       // ✅ update state of parent widget
  //       setState(() {
  //         selectedSound = selected;
  //       });
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setString('selectedSound', selected);
  //     }
  //   });
  // }
  TextEditingController speedController = TextEditingController();
  bool _isSpeedAlertEnabled = true;
  final String _alertPrefKey = "isSpeedAlertEnabled";

  Future<void> setSpeedAlertEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSpeedAlertEnabled', value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSpeedLimit();
  }

  List<double> speedOptions = [100, 200, 300, 400];
  double selectedValue = 100;
  int _speedLimit = 80;
  Future<void> _loadSpeedLimit() async {
    final dbLimit = await DatabaseHelper().getSpeedLimit();
    setState(() {
      _speedLimit = dbLimit.toInt();
    });
  }

  Widget build(BuildContext context) {
    //final Uri _url = Uri.parse('https://flutter.dev');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(

          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoryScreen()),
                );
              },
              icon: Icon(Icons.ice_skating),
            ),
          ],
          title: Text('Settings'),
        ),
        // extendBodyBehindAppBar: false,
        //backgroundColor: Color(0xffEFF7FF),

        body: ListView(
          padding: const EdgeInsets.all(9.0),
          children: [
            _buildSectionTitle("General"),
            SizedBox(
              height: 60, // ⬅️ Adjust height if needed
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ), // ✅ Border
                ),
                //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ⬅️ Outer spacing
                //color: Color(0xffFFFFFF),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0,0,0,0
                  ), // ⬅️ Inner padding
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(
                      10,
                      0,
                      0,
                      0,
                    ), // Remove default ListTile padding
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(5,5, 5,15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Speed Limit Alert",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mulish',
                            ),

                          ),
                          Transform.scale(



                            scale: 0.7,
                            child:   Switch(
                              activeColor: Colors.amber,
                              value: _isSpeedAlertEnabled,

                              onChanged: (value) async {
                                setState(() {

                                  _isSpeedAlertEnabled = value;
                                });
                                setSpeedAlertEnabled(value);
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _buildSettingsTile(
              "Speed Limit",
              " $_speedLimit km/h",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Set Speed Limit"),
                      content: DropdownButton<double>(
                        value: _speedLimit.toDouble(),
                        icon: Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        onChanged: (double? newValue) async {
                          if (newValue != null) {
                            setState(() {
                              selectedValue = newValue;
                            });
                            await DatabaseHelper().updateSpeedLimit(newValue);
                            await _loadSpeedLimit();
                            Navigator.of(context).pop(); // close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Speed limit updated to $newValue'),
                              ),
                            );
                          }
                        },
                        items: speedOptions.map<DropdownMenuItem<double>>((
                            double value,
                            ) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text("${value.toStringAsFixed(0)} km/h"),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),

            _buildSettingsTile(
              "History",
              "",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              ),
            ),

            SizedBox(height: 10),

            SizedBox(height: 10),
            _buildSectionTitle("Other"),
            _buildSettingsTile(
              "Rate Us",
              "",
              onTap: () {
                showRateUsDialog(context);
              },
            ),
            _buildSettingsTile("Privacy Policy","", onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (_)=>GaugeSelectionScreen()));
            }),
            _buildSettingsTile(
              "Share",
              "",
              onTap: () async {
                final params = ShareParams(
                  text:
                  'Check out my app: https://play.google.com/store/apps/details?id=com.yourcompany.app',
                  subject: 'Awesome Flutter App',
                );
                final result = await SharePlus.instance.share(params);

                if (result.status == ShareResultStatus.success) {
                  print('Thank you for sharing my website!');
                }
              },
            ),
            _buildSettingsTile(
              "Exit",
              "",
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Center(
                            child: Text(
                              "Exit",
                              style: TextStyle(
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  "Are you sure you want to exit?",
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      //  color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                    height: 40,
                                    width: 70,
                                    child: Center(
                                      child: Text(
                                        "CANCEL",
                                        style: TextStyle(
                                          color: Color(0xff7A7A7A),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Mulish',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    SystemNavigator.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Exit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.amber,
          fontFamily: 'Mulish',
          fontWeight: FontWeight.bold,
          //decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String label, label2, {VoidCallback? onTap}) {
    return SizedBox(
      height: 60, // ⬅️ Adjust height if needed
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1), // ✅ Border
        ),
        //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ⬅️ Outer spacing
        //color: Color(0xffFFFFFF),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ), // ⬅️ Inner padding
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(
              10,
              0,
              0,
              0,
            ), // Remove default ListTile padding
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mulish',
                  ),
                ),
                Text(
                  label2,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

Widget _buildSettingsTile2({
  required String label,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(title: Text(label), trailing: trailing, onTap: onTap);
}
