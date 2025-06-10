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

  static Future<void> deleteMenstruation(String documentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('menstruatie')
          .doc(documentId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Menstruatie data bestaat niet meer');
      }

      await docRef.delete();
    } catch (e) {
      throw Exception('Fout bij verwijderen menstruatie data: $e');
    }
  }

  Future<bool> updateMenstruationData({
    required String documentId,
    required DateTime selectedDay,
    required MenstruationData data,
    required String notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final firestoreData = {
        'datum': Timestamp.fromDate(selectedDay),
        'notities': notes,
        'bijgewerktOp': FieldValue.serverTimestamp(),
        ...data.toFirestoreData(),
      };

      await _firestore
          .collection('menstruatie')
          .doc(documentId)
          .update(firestoreData);
      return true;
    } catch (e) {
      print('Error updating menstruation data: $e');
      return false;
    }
  }
}
