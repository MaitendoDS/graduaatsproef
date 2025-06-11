import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Uint8List> generateHealthReport() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Geen gebruiker ingelogd');

    // Bereken datums voor afgelopen 3 maanden
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    
    // Haal alle gegevens op
    final symptoms = await _getSymptomsData(user.uid, threeMonthsAgo, now);
    final menstruation = await _getMenstruationData(user.uid, threeMonthsAgo, now);
    final food = await _getFoodData(user.uid, threeMonthsAgo, now);
    final userSettings = await _getUserSettings(user.uid);

    // Organiseer data per dag
    final dailyData = _organizeDailyData(symptoms, menstruation, food, threeMonthsAgo, now);

    // Genereer PDF
    final pdf = pw.Document();

    // Hoofdpagina
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildPatientInfo(user, userSettings),
            pw.SizedBox(height: 20),
            _buildReportPeriod(threeMonthsAgo, now),
            pw.SizedBox(height: 20),
            _buildOverallSummary(symptoms, menstruation, food, userSettings),
            pw.SizedBox(height: 20),
            _buildRecommendations(),
          ];
        },
      ),
    );

    // Dagelijkse details pagina's
    _addDailyDataPages(pdf, dailyData);

    return pdf.save();
  }

  static Map<String, Map<String, List<Map<String, dynamic>>>> _organizeDailyData(
    List<Map<String, dynamic>> symptoms,
    List<Map<String, dynamic>> menstruation,
    List<Map<String, dynamic>> food,
    DateTime start,
    DateTime end,
  ) {
    final dailyData = <String, Map<String, List<Map<String, dynamic>>>>{};

    // Initialiseer alle dagen
    for (var date = start; date.isBefore(end.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      dailyData[dateKey] = {
        'symptoms': [],
        'menstruation': [],
        'food': [],
      };
    }

    // Voeg symptomen toe per dag
    for (final symptom in symptoms) {
      final date = (symptom['datum'] as Timestamp).toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey]!['symptoms']!.add(symptom);
      }
    }

    // Voeg menstruatie toe per dag
    for (final period in menstruation) {
      final date = (period['datum'] as Timestamp).toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey]!['menstruation']!.add(period);
      }
    }

    // Voeg voeding toe per dag
    for (final foodItem in food) {
      final date = (foodItem['datum'] as Timestamp).toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey]!['food']!.add(foodItem);
      }
    }

    // Filter alleen dagen met data
    final filteredData = <String, Map<String, List<Map<String, dynamic>>>>{};
    dailyData.forEach((dateKey, data) {
      final hasData = data['symptoms']!.isNotEmpty || 
                     data['menstruation']!.isNotEmpty || 
                     data['food']!.isNotEmpty;
      if (hasData) {
        filteredData[dateKey] = data;
      }
    });

    return filteredData;
  }

  static void _addDailyDataPages(
    pw.Document pdf, 
    Map<String, Map<String, List<Map<String, dynamic>>>> dailyData
  ) {
    if (dailyData.isEmpty) return;

    final sortedDates = dailyData.keys.toList()..sort((a, b) => b.compareTo(a)); // Nieuwste eerst

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'Dagelijkse Gegevens Overzicht',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green700,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Hieronder vind je een overzicht van alle dagen waarop gegevens zijn geregistreerd.',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),
          ];

          for (final dateKey in sortedDates) {
            final data = dailyData[dateKey]!;
            final date = DateTime.parse(dateKey);
            
            widgets.add(_buildDaySection(date, data));
            widgets.add(pw.SizedBox(height: 16));
          }

          return widgets;
        },
      ),
    );
  }

  static pw.Widget _buildDaySection(
    DateTime date, 
    Map<String, List<Map<String, dynamic>>> data
  ) {
    final dayName = DateFormat('EEEE', 'nl').format(date);
    final dateFormatted = DateFormat('dd MMMM yyyy', 'nl').format(date);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Datum header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  '$dayName, $dateFormatted',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Menstruatie data
          if (data['menstruation']!.isNotEmpty) ...[
            _buildDataTypeSection('Menstruatie', data['menstruation']!, _formatMenstruationItem),
            pw.SizedBox(height: 8),
          ],

          // Symptomen data
          if (data['symptoms']!.isNotEmpty) ...[
            _buildDataTypeSection('Symptomen', data['symptoms']!, _formatSymptomItem),
            pw.SizedBox(height: 8),
          ],

          // Voeding data
          if (data['food']!.isNotEmpty) ...[
            _buildDataTypeSection('Voeding', data['food']!, _formatFoodItem),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildDataTypeSection(
    String title,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) formatter,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 6),
          ...items.map((item) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
            child: pw.Text(
              '- ${formatter(item)}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          )),
        ],
      ),
    );
  }

  static String _formatMenstruationItem(Map<String, dynamic> item) {
    final tijd = item['tijd'] ?? '';
    final symptoms = List<String>.from(item['symptoms'] ?? []);
    final notes = item['notities'] ?? '';

    String result = '';
    if (tijd.isNotEmpty) result += 'Tijd: $tijd';
    if (symptoms.isNotEmpty) {
      if (result.isNotEmpty) result += ' | ';
      result += 'Symptomen: ${symptoms.join(", ")}';
    }
    if (notes.isNotEmpty) {
      if (result.isNotEmpty) result += ' | ';
      result += 'Notities: $notes';
    }
    return result.isNotEmpty ? result : 'Menstruatie geregistreerd';
  }

  static String _formatSymptomItem(Map<String, dynamic> item) {
    final type = item['type'] ?? 'Onbekend';
    final locatie = item['locatie'] ?? '';
    final pijnschaal = item['pijnschaal'] ?? 0;
    final tijd = item['tijd'] ?? '';
    final notes = item['notities'] ?? '';

    String result = '$type';
    if (locatie.isNotEmpty) result += ' ($locatie)';
    result += ' - Pijn: $pijnschaal/10';
    if (tijd.isNotEmpty) result += ' om $tijd';
    if (notes.isNotEmpty) result += ' | $notes';
    
    return result;
  }

  static String _formatFoodItem(Map<String, dynamic> item) {
    final wat = item['wat'] ?? 'Onbekend gerecht';
    final tijd = item['tijd'] ?? '';
    final foodTypes = List<String>.from(item['foodTypes'] ?? []);
    final ingredienten = item['ingredienten'] ?? '';
    final allergenen = List<String>.from(item['allergenen'] ?? []);

    String result = wat;
    if (foodTypes.isNotEmpty) result += ' (${foodTypes.join(", ")})';
    if (tijd.isNotEmpty) result += ' om $tijd';
    if (ingredienten.isNotEmpty) result += ' | Ingrediënten: $ingredienten';
    if (allergenen.isNotEmpty) result += ' | Allergenen: ${allergenen.join(", ")}';
    
    return result;
  }

  static Future<List<Map<String, dynamic>>> _getSymptomsData(
    String uid, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('symptomen')
        .where('uid', isEqualTo: uid)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('datum', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _getMenstruationData(
    String uid, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('menstruatie')
        .where('uid', isEqualTo: uid)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('datum', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _getFoodData(
    String uid, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('voeding')
        .where('uid', isEqualTo: uid)
        .where('datum', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('datum', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('datum', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  static Future<Map<String, dynamic>?> _getUserSettings(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Unda Health Tracker',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
              pw.Text(
                'Gezondheidsrapport voor Huisarts',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            'Gegenereerd op: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(User user, Map<String, dynamic>? settings) {
    final birthDate = settings?['birthDate'] != null 
        ? (settings!['birthDate'] as Timestamp).toDate()
        : null;
    final age = birthDate != null 
        ? DateTime.now().year - birthDate.year 
        : null;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patiëntgegevens',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('E-mail: ${user.email}'),
              ),
              if (age != null)
                pw.Text('Leeftijd: $age jaar'),
            ],
          ),
          if (settings != null) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'Cyclusduur: ${settings['cycleLength'] ?? 28} dagen'
                  ),
                ),
                pw.Text(
                  'Menstruatieduur: ${settings['menstruationLength'] ?? 5} dagen'
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Seksueel actief: ${settings['sexuallyActive'] == true ? 'Ja' : 'Nee'}'
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildReportPeriod(DateTime start, DateTime end) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Text(
        'Rapportperiode: ${DateFormat('dd-MM-yyyy').format(start)} tot ${DateFormat('dd-MM-yyyy').format(end)} (3 maanden)',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildOverallSummary(
    List<Map<String, dynamic>> symptoms,
    List<Map<String, dynamic>> menstruation,
    List<Map<String, dynamic>> food,
    Map<String, dynamic>? settings,
  ) {
    final symptomsByType = <String, List<Map<String, dynamic>>>{};
    
    for (final symptom in symptoms) {
      final type = symptom['type'] ?? 'Onbekend';
      symptomsByType.putIfAbsent(type, () => []).add(symptom);
    }

    final avgPainScale = symptoms.isNotEmpty
        ? symptoms.map((s) => s['pijnschaal'] ?? 0).reduce((a, b) => a + b) / symptoms.length
        : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Algemeen Overzicht',
            style: pw.TextStyle(
              fontSize: 18, 
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Totaal aantal symptomen: ${symptoms.length}'),
                    pw.Text('Menstruatiedagen: ${menstruation.length}'),
                    pw.Text('Voedingsinvoer: ${food.length}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Gem. pijnschaal: ${avgPainScale.toStringAsFixed(1)}/10'),
                    pw.Text('Geschatte cycli: ${(90 / (settings?['cycleLength'] ?? 28)).ceil()}'),
                    pw.Text('Actieve dagen: ${_getActiveDaysCount(symptoms, menstruation, food)}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _getActiveDaysCount(
    List<Map<String, dynamic>> symptoms,
    List<Map<String, dynamic>> menstruation,
    List<Map<String, dynamic>> food,
  ) {
    final uniqueDates = <String>{};
    
    for (final item in [...symptoms, ...menstruation, ...food]) {
      final date = (item['datum'] as Timestamp).toDate();
      uniqueDates.add(DateFormat('yyyy-MM-dd').format(date));
    }
    
    return uniqueDates.length;
  }

  static pw.Widget _buildRecommendations() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Aanbevelingen voor Huisarts',
            style: pw.TextStyle(
              fontSize: 18, 
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('- Controleer patronen in symptomen en cyclus'),
          pw.Text('- Let op veranderingen in pijnschaal en duur'),
          pw.Text('- Overweeg voedingsallergie-onderzoek bij herhaalde allergenen'),
          pw.Text('- Monitor onregelmatigheden in menstruatiecyclus'),
          pw.Text('- Bekijk dagelijkse details op de volgende pagina'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Deze gegevens zijn verzameld via de Unda Health Tracker app en bedoeld als aanvullende informatie voor medische consultatie.',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static Future<String> savePdfToDevice(Uint8List pdfBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/unda_health_rapport_$timestamp.pdf');
    
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  static Future<void> sharePdf(Uint8List pdfBytes) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'unda_health_rapport_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}