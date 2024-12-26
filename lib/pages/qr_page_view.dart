import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

import '../auth.dart';
import 'last_login_page_view.dart';
import 'login_view.dart';

class QrPageView extends StatefulWidget {
  const QrPageView({super.key});

  @override
  _QrPageViewState createState() => _QrPageViewState();
}

class _QrPageViewState extends State<QrPageView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late int randomNumber;
  final Auth _auth = Auth();

  @override
  void initState() {
    super.initState();
    randomNumber = _auth.generateRandomNumber();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully")),
    );
  }

  Future<void> checkAndSaveData() async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xff132A50),
          title: const Text(
            "Enable Location Services",
            style: TextStyle(color: Colors.grey),
          ),
          content: const Text(
            "Location services are required. Please enable Location.",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Allow",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Deny",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );

      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Location permission permanently denied. Change settings."),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print('Latitude: ${position.latitude}, Longitude:${position.longitude}');
    _auth.saveData(context, randomNumber.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Wait for a minute."),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff132A50),
      body: SingleChildScrollView(
        child: Stack(children: [
          Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    height: 90,
                    color: const Color(0xff132A50),
                  ),
                  Positioned(
                    right: -15,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xff223E75),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: TextButton(
                          onPressed: signOut,
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      height: height - 89,
                      width: width,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(30, 20),
                          topRight: Radius.elliptical(30, 20),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 250),
                          Container(
                            height: 200,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomPaint(
                                painter: ContainerPaint(),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "",
                                      style: const TextStyle(
                                        fontSize: 35,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    const Text(
                                      "Generated Number",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "$randomNumber",
                                      style: const TextStyle(
                                        fontSize: 35,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LastLoginPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 60,
                              width: width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('login_details')
                                      .where(
                                        'timestamp',
                                        isGreaterThanOrEqualTo: DateTime.now()
                                            .toIso8601String()
                                            .split('T')
                                            .first,
                                      )
                                      .orderBy('timestamp', descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data?.docs == null) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final todayTasks = snapshot.data!.docs;
                                    if (todayTasks.isEmpty) {
                                      return const Center(
                                          child: Text(
                                              "No tasks found for today."));
                                    }

                                    final firstTask = todayTasks.first;
                                    final timestamp =
                                        DateTime.parse(firstTask["timestamp"]);
                                    final formattedTime = DateFormat('hh:mm aa')
                                        .format(timestamp);
                                    final now = DateTime.now();
                                    final difference =
                                        now.difference(timestamp).inDays;

                                    String timeLabel = '';
                                    if (difference == 0) {
                                      timeLabel = 'Today';
                                    } else if (difference == 1) {
                                      timeLabel = 'Yesterday';
                                    }
                                    return Text(
                                      "Last Login at ${timeLabel}, ${formattedTime}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: checkAndSaveData,
                                child: Container(
                                  height: 60,
                                  width: width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "SAVE",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: width * 0.25,
                    right: width * 0.25,
                    child: Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: QrImageView(data: randomNumber.toString()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
              top: 65,
              left: 0,
              right: 0,
              child: Center(
                  child: Container(
                height: 45,
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xff0766AB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "PLUGIN",
                    style: TextStyle(fontSize: 30, color: Colors.white70),
                  ),
                ),
              ))),
        ]),
      ),
    );
  }
}

class ContainerPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint()..color = const Color(0xff132A50);
    Paint paint2 = Paint()..color = const Color(0xff1E1E1E);

    Path path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    Path path2 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
