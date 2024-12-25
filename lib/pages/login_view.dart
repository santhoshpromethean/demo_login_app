import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController =
      TextEditingController(text: "+91");
  final TextEditingController _otpController = TextEditingController();
  String? _verifyId;
  String? _errmsg;

  Future printIps() async {
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4) {
          print(address.address);
        }
      }
    }
  }

  void sendOTP() async {
    try {
      await Auth().verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        onCodeSent: (String verificationId) {
          setState(() {
            _verifyId = verificationId;
          });
        },
        onError: (FirebaseAuthException e) {
          setState(() {
            _errmsg = "Enter Valid Phone Number";
          });
        },
        onVerified: (credential) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
              "Verified.",
              style: TextStyle(fontFamily: "Nunito"),
            )),
          );
        },
      );
    } catch (e) {
      setState(() {
        _errmsg = "Enter Valid Phone Number";
      });
    }
  }

  void verifyOTP() async {
    try {
      if (_verifyId != null) {
        await Auth().signInWithOTP(
          verificationId: _verifyId!,
          otp: _otpController.text.trim(),
        );
      }
    } catch (e) {
      setState(() {
        _errmsg = "Invalid OTP";
      });
    }
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
                    color: Color(0xff132A50),
                  ),
                  const Positioned(
                    right: -15,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Color(0xff223E75),
                    ),
                  ),
                ],
              ),
              Container(
                height: height - 89,
                width: width,
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(30, 20),
                        topRight: Radius.elliptical(30, 20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Phone Number",
                          style: TextStyle(fontSize: 25, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      height: 50,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xff132A50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: TextField(
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                    suffix: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: GestureDetector(
                                          onTap: sendOTP,
                                          child: const Text(
                                            "Send OTP",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          )),
                                    ),
                                    hintStyle: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    border: InputBorder.none),
                                keyboardType: TextInputType.phone,
                                maxLength: 13,
                                buildCounter: (BuildContext context,
                                    {required int currentLength,
                                    required bool isFocused,
                                    required int? maxLength}) {
                                  return null;
                                },
                                controller: _phoneController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    const Row(
                      children: [
                        Text(
                          "OTP",
                          style: TextStyle(fontSize: 25, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      height: 50,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xff132A50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: TextField(
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    border: InputBorder.none),
                                keyboardType: TextInputType.phone,
                                maxLength: 6,
                                buildCounter: (BuildContext context,
                                    {required int currentLength,
                                    required bool isFocused,
                                    required int? maxLength}) {
                                  return null;
                                },
                                controller: _otpController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    if (_errmsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errmsg!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: height * 0.04),
                    GestureDetector(
                        onTap: verifyOTP,
                        child: Container(
                            height: 60,
                            width: width,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))),
                    TextButton(onPressed: printIps, child: Text("hbsxhx"))
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
                      width: width * .4,
                      decoration: BoxDecoration(
                          color: Color(0xff0766AB),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Text(
                          "LOGIN",
                          style: TextStyle(fontSize: 30, color: Colors.white70),
                        ),
                      )))),
        ]),
      ),
    );
  }
}
