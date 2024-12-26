import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_app_demo/pages/login_view.dart';

import '../auth.dart';

class LastLoginPage extends StatefulWidget {
  const LastLoginPage({super.key});

  @override
  State<LastLoginPage> createState() => _LastLoginPageState();
}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class _LastLoginPageState extends State<LastLoginPage>
    with SingleTickerProviderStateMixin {
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePressed(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xff132A50),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      height: 90,
                      color: const Color(0xff132A50),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "<",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.grey),
                            ),
                          )
                        ],
                      ),
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
                            onPressed: () async {
                              signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Logged out.")));
                            },
                            child: const Text(
                              "Logout",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
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
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          CustomButton(
                            value: "Today",
                            isSelected: _selectedIndex == 0,
                            onPressed: () => _togglePressed(0),
                            width: 70,
                          ),
                          const SizedBox(width: 15),
                          CustomButton(
                            value: "Yesterday",
                            isSelected: _selectedIndex == 1,
                            onPressed: () => _togglePressed(1),
                            width: 70,
                          ),
                          const SizedBox(width: 15),
                          CustomButton(
                            width: 70,
                            value: "Others",
                            onPressed: () => _togglePressed(2),
                            isSelected: _selectedIndex == 2,
                          ),
                        ],
                      ),
                      Expanded(
                          child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: const [
                          TodaySection(),
                          YesterdaySection(),
                          OthersSection(),
                        ],
                      )),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
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
                    ],
                  ),
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
                      "LAST LOGIN",
                      style: TextStyle(fontSize: 30, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodaySection extends StatefulWidget {
  const TodaySection({super.key});

  @override
  State<TodaySection> createState() => _TodaySectionState();
}

class _TodaySectionState extends State<TodaySection> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('login_details')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo:
                DateTime.now().toIso8601String().split('T').first,
          )
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data?.docs == null || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayTasks = snapshot.data!.docs;
        return ListView.builder(
          itemCount: todayTasks.length,
          itemBuilder: (context, index) {
            final doc = todayTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('hh:mm aa')
                                  .format(DateTime.parse(doc["timestamp"])),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "IP : ${doc["address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${doc["geo_address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 80,
                      width: 80,
                      child: doc["qr_code_url"] != null &&
                              doc["qr_code_url"].toString().isNotEmpty
                          ? Image.network(
                              doc["qr_code_url"],
                              scale: 3,
                            )
                          : const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class YesterdaySection extends StatefulWidget {
  const YesterdaySection({super.key});

  @override
  State<YesterdaySection> createState() => _YesterdaySectionState();
}

class _YesterdaySectionState extends State<YesterdaySection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('login_details')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data?.docs == null || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        final yesterdayEnd = todayStart;

        final yesterdayTasks = snapshot.data!.docs.where((doc) {
          final timestamp = DateTime.parse(doc["timestamp"]);
          return timestamp.isAfter(yesterdayStart) &&
              timestamp.isBefore(yesterdayEnd);
        }).toList();

        return ListView.builder(
          itemCount: yesterdayTasks.length,
          itemBuilder: (context, index) {
            final doc = yesterdayTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('hh:mm aa')
                                  .format(DateTime.parse(doc["timestamp"])),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "IP : ${doc["address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${doc["geo_address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 80,
                      width: 80,
                      child: doc["qr_code_url"] != null &&
                              doc["qr_code_url"].toString().isNotEmpty
                          ? Image.network(
                              doc["qr_code_url"],
                              scale: 3,
                            )
                          : const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class OthersSection extends StatefulWidget {
  const OthersSection({super.key});

  @override
  State<OthersSection> createState() => _OthersSectionState();
}

class _OthersSectionState extends State<OthersSection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('login_details')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data?.docs == null || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        final othersTasks = snapshot.data!.docs.where((doc) {
          final timestamp = DateTime.parse(doc["timestamp"]);
          return timestamp.isBefore(yesterdayStart);
        }).toList();

        return ListView.builder(
          itemCount: othersTasks.length,
          itemBuilder: (context, index) {
            final doc = othersTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('hh:mm aa')
                                  .format(DateTime.parse(doc["timestamp"])),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "IP : ${doc["address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${doc["geo_address"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 80,
                      width: 80,
                      child: doc["qr_code_url"] != null &&
                              doc["qr_code_url"].toString().isNotEmpty
                          ? Image.network(
                              doc["qr_code_url"],
                              scale: 3,
                            )
                          : const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String value;
  final double width;
  final bool isSelected;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onPressed,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(children: <Widget>[
        Container(
          width: width,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(0),
          ),
          // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: width,
            height: 4.0,
            color: isSelected ? Colors.grey : Colors.black,
          ),
        ),
      ]),
    );
  }
}
