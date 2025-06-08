
import 'package:cloud_firestore/cloud_firestore.dart';

class MenstruationData {
  final String uid;
  final DateTime datum;
  final List<String> sexOptions;
  final List<String> symptoms;
  final List<String> dischargeAmount;
  final List<String> dischargeType;
  final List<String> other;
  final String notities;
  final DateTime? aangemaaktOp;

  MenstruationData({
    required this.uid,
    required this.datum,
    required this.sexOptions,
    required this.symptoms,
    required this.dischargeAmount,
    required this.dischargeType,
    required this.other,
    required this.notities,
    this.aangemaaktOp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'datum': Timestamp.fromDate(datum),
      'sexOptions': sexOptions,
      'symptoms': symptoms,
      'dischargeAmount': dischargeAmount,
      'dischargeType': dischargeType,
      'other': other,
      'notities': notities.trim(),
      'aangemaaktOp': FieldValue.serverTimestamp(),
    };
  }
}
