import 'package:cloud_firestore/cloud_firestore.dart';

class FoodData {
  final String uid;
  final DateTime datum;
  final String tijd;
  final List<String> foodTypes;
  final String wat;
  final String ingredienten;
  final List<String> allergenen;
  final String notities;
  final DateTime? aangemaaktOp;

  FoodData({
    required this.uid,
    required this.datum,
    required this.tijd,
    required this.foodTypes,
    required this.wat,
    required this.ingredienten,
    required this.allergenen,
    required this.notities,
    this.aangemaaktOp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'datum': Timestamp.fromDate(datum),
      'tijd': tijd,
      'foodTypes': foodTypes,
      'wat': wat.trim(),
      'ingredienten': ingredienten.trim(),
      'allergenen': allergenen,
      'notities': notities.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };
  }

  factory FoodData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return FoodData(
      uid: data?['uid'] ?? '',
      datum: (data?['datum'] as Timestamp).toDate(),
      tijd: data?['tijd'] ?? '',
      foodTypes: List<String>.from(data?['foodTypes'] ?? []),
      wat: data?['wat'] ?? '',
      ingredienten: data?['ingredienten'] ?? '',
      allergenen: List<String>.from(data?['allergenen'] ?? []),
      notities: data?['notities'] ?? '',
      aangemaaktOp: data?['aangemaaktOp'] != null 
        ? (data!['aangemaaktOp'] as Timestamp).toDate()
        : null,
    );
  }
}