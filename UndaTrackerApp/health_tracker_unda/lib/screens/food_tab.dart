import 'package:flutter/material.dart';

import '../constants/food_constants.dart';
import '../models/food_data.dart';
import '../services/food_service.dart';
import '../widgets/forms/food_form.dart';

class FoodTab extends StatefulWidget {
  final DateTime selectedDay;
  final FoodData? initialData;  // Voor edit mode
  final bool isEditing;         // Is dit een edit of nieuwe entry
  final String? documentId;     // Document ID voor updates

  const FoodTab({
    super.key, 
    required this.selectedDay,
    this.initialData,
    this.isEditing = false,
    this.documentId,
  });

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  bool _isLoading = false;

  Future<void> _handleSave(FoodData foodData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEditing && widget.documentId != null) {
        // UPDATE bestaande entry
        await FoodService.updateFoodEntry(widget.documentId!, foodData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Voedingsgegevens bijgewerkt'),
              backgroundColor: FoodConstants.successGreen,
            ),
          );
          Navigator.pop(context, true); // Return true voor refresh
        }
      } else {
        // CREATE nieuwe entry
        await FoodService.saveFoodEntry(foodData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(FoodConstants.successMessage),
              backgroundColor: FoodConstants.successGreen,
            ),
          );
          Navigator.pop(context, true); // Return true voor refresh
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = FoodConstants.noUserMessage;
        
        if (e.toString().contains('Geen gebruiker ingelogd')) {
          errorMessage = FoodConstants.noUserMessage;
        } else {
          errorMessage = '${FoodConstants.saveErrorPrefix}$e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: FoodConstants.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodConstants.backgroundGrey,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Voeding bewerken' : FoodConstants.appBarTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: FoodConstants.primaryFoodColor,
                  ),
                  SizedBox(height: 16),
                  Text('Bezig met opslaan...'),
                ],
              ),
            )
          : FoodForm(
              selectedDay: widget.selectedDay,
              onSave: _handleSave,
              initialData: widget.initialData,
            ),
    );
  }
}