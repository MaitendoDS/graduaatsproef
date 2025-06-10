
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/menstruation_data.dart';


class MenstruationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> saveMenstruationData({
    required DateTime selectedDay,
    required MenstruationData data,
    required String notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final firestoreData = {
        'uid': user.uid,
        'datum': Timestamp.fromDate(selectedDay),
        'notities': notes,
        'aangemaaktOp': FieldValue.serverTimestamp(),
        ...data.toFirestoreData(),
      };

      await _firestore.collection('menstruatie').add(firestoreData);
      return true;
    } catch (e) {
      print('Error saving menstruation data: $e');
      return false;
    }
  }
}