import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/symptom_data.dart';

class SymptomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> saveSymptom(SymptomData symptomData) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return "Geen gebruiker ingelogd";
      }

      if (!symptomData.isValid) {
        if (symptomData.selectedType == null) {
          return "Selecteer een type symptoom";
        }
        if (symptomData.location.trim().isEmpty) {
          return "Vul een locatie in";
        }
      }

      final data = symptomData.toFirestoreData(user.uid);
      await _firestore.collection('symptomen').add(data);
      
      return null; // null betekent success
    } catch (e) {
      return 'Fout bij opslaan: $e';
    }
  }
}