import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get user cycle settings
  Future<Map<String, dynamic>?> getUserCycleData() async {
    if (currentUserId == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting user cycle data: $e');
    }
    return null;
  }

  // Get symptoms for a specific date
  Future<List<Map<String, dynamic>>> getSymptomsForDate(DateTime date) async {
    if (currentUserId == null) return [];
    
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      
      QuerySnapshot query = await _firestore
          .collection('symptomen')
          .where('uid', isEqualTo: currentUserId)
          .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('datum', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('datum', descending: true)
          .get();
      
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      print('Error getting symptoms: $e');
      return [];
    }
  }

  // Get menstruation data for a specific date
  Future<Map<String, dynamic>?> getMenstruationForDate(DateTime date) async {
    if (currentUserId == null) return null;
    
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      
      QuerySnapshot query = await _firestore
          .collection('menstruatie')
          .where('uid', isEqualTo: currentUserId)
          .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('datum', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return {
          'id': query.docs.first.id,
          ...query.docs.first.data() as Map<String, dynamic>
        };
      }
    } catch (e) {
      print('Error getting menstruation data: $e');
    }
    return null;
  }

  // Get all menstruation dates for cycle calculation
Future<List<DateTime>> getAllMenstruationDates() async {
  if (currentUserId == null) return [];
  
  try {
    QuerySnapshot query = await _firestore
        .collection('menstruatie')
        .where('uid', isEqualTo: currentUserId)
        .orderBy('datum', descending: true)
        .get();
    
    return query.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Timestamp timestamp = data['datum'] as Timestamp;
      return timestamp.toDate();
    }).toList();
  } catch (e) {
    print('Error getting menstruation dates: $e');
    return [];
  }
}

Future<Map<String, List<Map<String, dynamic>>>> getFoodForDateRange(DateTime start, DateTime end) async {
  if (currentUserId == null) return {};
  
  try {
    final snapshot = await FirebaseFirestore.instance
      .collection('voeding')
      .where('uid', isEqualTo: currentUserId)
      .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(end))
      .get();

    Map<String, List<Map<String, dynamic>>> foodByDate = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime datum = (data['datum'] as Timestamp).toDate();
      String key = '${datum.year}-${datum.month}-${datum.day}';

      if (!foodByDate.containsKey(key)) {
        foodByDate[key] = [];
      }

      // ⭐ BELANGRIJK: Voeg document ID toe aan data
      final foodData = {
        'id': doc.id,  // Document ID toevoegen!
        ...data,       // Alle andere data
      };

      foodByDate[key]!.add(foodData);
      
      print('Added food item with ID: ${doc.id}'); // Debug log
    }

    return foodByDate;
  } catch (e) {
    print('Error getting food for date range: $e');
    return {};
  }
}
Future<Map<String, List<Map<String, dynamic>>>> getSymptomsForDateRange(
  DateTime startDate, 
  DateTime endDate
) async {
  if (currentUserId == null) return {};
  
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('symptomen')
        .where('uid', isEqualTo: currentUserId)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    Map<String, List<Map<String, dynamic>>> symptomsMap = {};
    
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['datum'] as Timestamp).toDate();
      String dateKey = '${date.year}-${date.month}-${date.day}';
      
      if (!symptomsMap.containsKey(dateKey)) {
        symptomsMap[dateKey] = [];
      }
      
      // ⭐ BELANGRIJK: Voeg document ID toe
      symptomsMap[dateKey]!.add({
        'id': doc.id,  // Document ID toevoegen!
        ...data
      });
      
      print('Added symptom with ID: ${doc.id}'); // Debug log
    }
    
    return symptomsMap;
  } catch (e) {
    print('Error getting symptoms for date range: $e');
    return {};
  }
}

Future<Map<String, Map<String, dynamic>>> getMenstruationForDateRange(
  DateTime startDate, 
  DateTime endDate
) async {
  if (currentUserId == null) return {};
  
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('menstruatie')
        .where('uid', isEqualTo: currentUserId)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    Map<String, Map<String, dynamic>> menstruationMap = {};
    
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['datum'] as Timestamp).toDate();
      String dateKey = '${date.year}-${date.month}-${date.day}';
      
      // ⭐ BELANGRIJK: Voeg document ID toe
      menstruationMap[dateKey] = {
        'id': doc.id,  // Document ID toevoegen!
        ...data
      };
      
      print('Added menstruation with ID: ${doc.id}'); // Debug log
    }
    
    return menstruationMap;
  } catch (e) {
    print('Error getting menstruation for date range: $e');
    return {};
  }
}
}