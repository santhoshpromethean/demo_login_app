import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerified,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onError,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        onVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithOTP({
    required String verificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  int generateRandomNumber() {
    return Random().nextInt(1000000);
  }

  Future<String> saveQR(String randomNumber) async {
    final storageRef =
        FirebaseStorage.instance.ref("qr_codes/$randomNumber.png");

    final qrPainter = QrPainter(
      data: randomNumber,
      version: QrVersions.auto,
      gapless: false,
    );

    final image = await qrPainter.toImage(200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageData = byteData!.buffer.asUint8List();

    final uploadTask = await storageRef.putData(imageData);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> saveToFirestore(
      String number, String qrUrl, String geoAddress) async {
    try {
      String? ipAddress;
      for (var interface in await NetworkInterface.list()) {
        for (var address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            ipAddress = address.address;
            break;
          }
        }
        if (ipAddress != null) break;
      }

      await FirebaseFirestore.instance.collection('login_details').add({
        'address': ipAddress ?? "unknown",
        'geo_address': geoAddress,
        'random_number': number,
        'timestamp': DateTime.now().toIso8601String(),
        'qr_code_url': qrUrl,
      });
    } catch (e) {
      print("Failed to save data: $e");
    }
  }

  Future<void> saveData(BuildContext context, String randomNumber) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String geoAddress = "${position.latitude}, ${position.longitude}";
      final qrUrl = await saveQR(randomNumber);
      await saveToFirestore(randomNumber, qrUrl, geoAddress);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User does not have permission to access."),
          duration: Duration(seconds: 1),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Login."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
