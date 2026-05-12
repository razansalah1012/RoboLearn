import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Run this to test Firestore connectivity
void testFirestore() async {
  try {
    print("Testing Firestore connectivity...");
    final db = FirebaseFirestore.instance;
    await db.collection('test_connection').add({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Connectivity test',
    });
    print("SUCCESS: Firestore is reachable and writable!");
  } catch (e) {
    print("FAILURE: Firestore write failed. Error: $e");
    if (e.toString().contains('permission-denied')) {
      print("SUGGESTION: Check your Firestore Security Rules in the Firebase Console.");
    }
  }
}
